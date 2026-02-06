import "request/subgraph/edge-cache-regime" as edgeCacheRegimeHandler;
import "request/subgraph/request-header-forwarder" as requestHeaderForwarder;

fn process_request(request) {
    log_info("SUBGRAPH REQUEST STARTED");
    edgeCacheRegimeHandler::setCacheRegimeHeaderFromContext(request);
    requestHeaderForwarder::setRequestHeaders(request);
}