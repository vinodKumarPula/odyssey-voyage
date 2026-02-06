import "response/subgraph/cache-control" as cacheControl;
import "response/subgraph/cache-tags" as cacheTags;
import "response/subgraph/datasource-insight" as datasourceInsight;
import "response/subgraph/response-header-forwarder" as responseHeaderForwarder;
import "response/subgraph/set-cookie" as setCookie;
import "response/subgraph/response-error-header" as responseErrorHeader;

fn process_response(response) {
    log_info("SUBGRAPH SENDING RESPONSE");
    responseHeaderForwarder::storeResponseHeadersInContext(response);
    setCookie::storeSubgraphResponseSetCookieHeaderInContext(response);
    cacheControl::queue_cache_control(response);
    datasourceInsight::storeDataSourceInsightsInContext(response);
    cacheTags::storeCacheTagsInContext(response);
    responseErrorHeader::storeResponseErrorHeaderInContext(response);
}
