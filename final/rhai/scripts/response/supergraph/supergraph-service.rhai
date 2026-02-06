import "response/supergraph/cache-control" as cacheControl;
import "response/supergraph/cache-tags" as cacheTags;
import "response/supergraph/error-handler" as errorHandler;
import "response/supergraph/datasource-insight" as datasourceInsight;
import "response/supergraph/response-header-forwarder" as responseHeaderForwarder;
import "response/supergraph/set-cookie" as setCookie;
import "util" as util;
import "response/supergraph/operational-response-headers" as operationalResponseHeaders;
import "response/supergraph/response-error-header" as responseErrorHeader;

fn process_response(response) {
    log_info("SENDING RESPONSE"+ response?.body);
    if response.is_primary() {
        let modifyErrorExtensions = util::getEnv("MODIFY_ERROR_EXTENSIONS", "true") == "true";
        let enableOperationalResponseHeaders = util::getEnv("ENABLE_OPERATIONAL_RESPONSE_HEADERS", "true") == "true";
        let enableResponseErrorHeader = util::getEnv("ENABLE_RESPONSE_ERROR_HEADER", "true") == "true";
        if modifyErrorExtensions {
            errorHandler::formatError(response);
        }
        responseHeaderForwarder::copyResponseHeadersInResponse(response);
        setCookie::copySetCookieResponseHeader(response);
        cacheControl::resolve_cache_control(response);
        datasourceInsight::copyDatasourceInsightToResponse(response);
        cacheTags::setCacheTagHeaderInSupergraphResponse(response);
        if enableOperationalResponseHeaders {
            operationalResponseHeaders::setOperationalResponseHeaders(response);
        }
        if enableResponseErrorHeader {
            responseErrorHeader::setUxlResponseErrorHeaderInSuperGraphResponse(response);
        }
    }
}
