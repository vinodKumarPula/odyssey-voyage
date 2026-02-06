
import "util" as util;


// Get the Mandatory request headers
fn getMandatoryRequestHeaders() {
    ["apollographql-client-name","apollographql-client-version"]
}

// Get the Mandatory Tracing request headers
fn getMandatoryTracingRequestHeaders() {
    ["x-request-id","correlation-id"]
}

fn parseURLOperationName(request) {
    let uri = `${request.uri}`;
    let operationNameFromPath = request.uri.path.split_rev("/")[0];

    //Return if we have the operation name in the path
    if (operationNameFromPath != () && operationNameFromPath.len > 0) {
        return operationNameFromPath;
    }

    //Return if we have the operation name in the query params
    let operationNameFromQuery = util::getQueryParameter(request);
    if (operationNameFromQuery != () && operationNameFromQuery.len > 0) {
        return operationNameFromQuery;
    }

    ();
}

fn throwError(message) {
    throw  #{
                status: 400,
                body: #{
                    errors: [#{
                        message: message,
                        extensions: #{
                            "code": "Bad Request"
                        }
                    }]
                }
            };
}

fn setOperationNamePropertiesInContext(request) {

    const HEADER_KEY_OPERATION_NAME = "graphql-operation-name";
    const MISSING_OPERATION_NAME_ERROR = "operation name is missing";
    const OPERATION_NAME_MISMATCH_ERROR = "operation names do not match";
    const enableOperationNameCheck = util::getEnv("ENABLE_OPERATION_NAME_CHECK","false");
    const enableOperationNameInHeader =  util::getEnv("ENABLE_OPERATION_IN_HEADER","false");

    if (enableOperationNameCheck == "true") {
        let operationNameFromHeader = "";
        let operationNameFromBody = "";
        const operationNameFromURL = parseURLOperationName(request);
        if request.body.operation_name != () {
            operationNameFromBody = request.body.operation_name;
        }
        if (util::containsHeader(request, HEADER_KEY_OPERATION_NAME)) {
            operationNameFromHeader = request.headers[HEADER_KEY_OPERATION_NAME];
        }
        let operationNameCheckProperties = #{
            enableOperationNameCheck: enableOperationNameCheck,
            enableOperationNameInHeader: enableOperationNameInHeader,
            operationNameFromHeader: operationNameFromHeader,
            operationNameFromBody: operationNameFromBody,
            operationNameFromURL: operationNameFromURL
        };

        request.context["operationNameCheckProperties"] = operationNameCheckProperties;
    }

}

fn getEnableCapturingOperationPathEnv() {
    return util::getEnv("ENABLE_CAPTURING_OPERATION_PATH","true");
}

fn getMaxDepthEnv() {
    return util::getEnv("MAX_DEPTH","3");
}

fn getRootOperationPathEnv(request) {
    request.headers["enable_capturing_operation_path"] = getEnableCapturingOperationPathEnv();
    request.headers["max_depth"] = getMaxDepthEnv();
    return request;
}

/**
Validate the request
*/
fn validateRequest(request) {
    let errors = [];

    for mandatoryHeader in getMandatoryRequestHeaders() {
        if !util::containsHeader(request,mandatoryHeader) {
            errors.push(mandatoryHeader);
        }
    }
    const tracingHeaders = getMandatoryTracingRequestHeaders();
    const tracingHeaderExists = tracingHeaders.some(|tracingHeader| util::containsHeader(request,tracingHeader));

    if(!tracingHeaderExists){
        errors.push(util::join(tracingHeaders," or "));
    }

    if !errors.is_empty() {
        const message =  if errors.len == 1 { "header is" } else { "headers are"};
        throw  #{
            status: 500,
            body: #{
                errors: [#{
                    message: `The following mandatory ${message} missing: ${util::join(errors,", ")}`,
                    extensions: #{
                        "code": "INTERNAL_SERVER_ERROR"
                    }
                }]
            }
        };
    }
    setOperationNamePropertiesInContext(request);
    getRootOperationPathEnv(request);
}