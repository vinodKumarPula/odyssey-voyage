import "util" as util;

/**
  Forward headers received from a subgraph to requests of other subgraphs.
  Note, the headers received from subgraphs are placed in context in 
    the storeResponseHeadersInContext function in response-header-forwarder.rhai
*/
fn setRequestHeaders(request) {
    for headerName in util::getSubgraphResponseHeadersToForwardToSubgraphs() {
        let headerValue = request?.context[headerName];
        if headerValue != () {
          request.subgraph.headers[headerName] = headerValue;
        } 
    }
}
