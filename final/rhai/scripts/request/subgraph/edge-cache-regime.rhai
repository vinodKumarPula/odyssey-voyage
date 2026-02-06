fn setCacheRegimeHeaderFromContext(request) {
    let cache_regime = request?.context["cache_request_regime"];
    if(cache_regime == "CLIENT_DRIVEN" || cache_regime == "SERVER_DRIVEN") {
        request.subgraph.headers["uxl-edge-cache-request-regime"] = [cache_regime];
    }
}
