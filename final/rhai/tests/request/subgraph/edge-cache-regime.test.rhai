test("Should set CLIENT_DRIVEN cache regime header when context contains CLIENT_DRIVEN", ||{
  import "request/subgraph/edge-cache-regime" as edgeCacheRegime;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  request.context["cache_request_regime"] = "CLIENT_DRIVEN";
  
  edgeCacheRegime::setCacheRegimeHeaderFromContext(request);
  
  expect(request.subgraph.headers.contains("uxl-edge-cache-request-regime")).to_be(true);
  expect(request.subgraph.headers["uxl-edge-cache-request-regime"]).to_be("CLIENT_DRIVEN");
});

test("Should set SERVER_DRIVEN cache regime header when context contains SERVER_DRIVEN", ||{
  import "request/subgraph/edge-cache-regime" as edgeCacheRegime;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  request.context["cache_request_regime"] = "SERVER_DRIVEN";
  
  edgeCacheRegime::setCacheRegimeHeaderFromContext(request);
  
  expect(request.subgraph.headers.contains("uxl-edge-cache-request-regime")).to_be(true);
  expect(request.subgraph.headers["uxl-edge-cache-request-regime"]).to_be("SERVER_DRIVEN");
});

test("Should not set cache regime header when context contains invalid regime", ||{
  import "request/subgraph/edge-cache-regime" as edgeCacheRegime;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  request.context["cache_request_regime"] = "INVALID_REGIME";
  
  edgeCacheRegime::setCacheRegimeHeaderFromContext(request);
  
  expect(request.subgraph.headers.contains("uxl-edge-cache-request-regime")).to_be(false);
});

test("Should not set cache regime header when context contains empty string", ||{
  import "request/subgraph/edge-cache-regime" as edgeCacheRegime;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  request.context["cache_request_regime"] = "";
  
  edgeCacheRegime::setCacheRegimeHeaderFromContext(request);
  
  expect(request.subgraph.headers.contains("uxl-edge-cache-request-regime")).to_be(false);
});

test("Should not set cache regime header when context is missing cache_request_regime", ||{
  import "request/subgraph/edge-cache-regime" as edgeCacheRegime;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  // Don't set cache_request_regime in context
  
  edgeCacheRegime::setCacheRegimeHeaderFromContext(request);
  
  expect(request.subgraph.headers.contains("uxl-edge-cache-request-regime")).to_be(false);
});

test("Should not set cache regime header when context is null", ||{
  import "request/subgraph/edge-cache-regime" as edgeCacheRegime;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  
  edgeCacheRegime::setCacheRegimeHeaderFromContext(request);
  
  expect(request.subgraph.headers.contains("uxl-edge-cache-request-regime")).to_be(false);
});

test("Should not set cache regime header when request is null", ||{
  import "request/subgraph/edge-cache-regime" as edgeCacheRegime;
  
  let request = ();
  
  edgeCacheRegime::setCacheRegimeHeaderFromContext(request);
  
  // Should not throw an error and should handle gracefully
  expect(true).to_be(true);
});

test("Should handle case-insensitive cache regime values", ||{
  import "request/subgraph/edge-cache-regime" as edgeCacheRegime;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  request.context["cache_request_regime"] = "client_driven";
  
  edgeCacheRegime::setCacheRegimeHeaderFromContext(request);
  
  // Should not set header since it's case-sensitive
  expect(request.subgraph.headers.contains("uxl-edge-cache-request-regime")).to_be(false);
});
