import "request/supergraph/request-validation" as requestValidation;
import "request/supergraph/modify-headers" as modifyHeaders;

fn process_request(request) {    
    print("INSIDE PROCESS"+ request);
    requestValidation::validateRequest(request);
    modifyHeaders::reassignAuthorizationHeader(request);
}