test("Should forward uxl-migration-status header from context to subgraph headers", ||{
  import "request/subgraph/request-header-forwarder" as requestHeaderForwarder;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  request.context["uxl-migration-status"] = "migrated";
  
  requestHeaderForwarder::setRequestHeaders(request);
  
  expect(request.subgraph.headers.contains("uxl-migration-status")).to_be(true);
  expect(request.subgraph.headers["uxl-migration-status"]).to_be("migrated");
});

test("Should forward uxl-cart-id header from context to subgraph headers", ||{
  import "request/subgraph/request-header-forwarder" as requestHeaderForwarder;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  request.context["uxl-cart-id"] = "cart-12345";
  
  requestHeaderForwarder::setRequestHeaders(request);
  
  expect(request.subgraph.headers.contains("uxl-cart-id")).to_be(true);
  expect(request.subgraph.headers["uxl-cart-id"]).to_be("cart-12345");
});

test("Should forward multiple headers from context to subgraph headers", ||{
  import "request/subgraph/request-header-forwarder" as requestHeaderForwarder;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  request.context["uxl-migration-status"] = "migrated";
  request.context["uxl-cart-id"] = "cart-67890";
  
  requestHeaderForwarder::setRequestHeaders(request);
  
  expect(request.subgraph.headers.contains("uxl-migration-status")).to_be(true);
  expect(request.subgraph.headers["uxl-migration-status"]).to_be("migrated");
  expect(request.subgraph.headers.contains("uxl-cart-id")).to_be(true);
  expect(request.subgraph.headers["uxl-cart-id"]).to_be("cart-67890");
});

test("Should not forward headers that are not in context", ||{
  import "request/subgraph/request-header-forwarder" as requestHeaderForwarder;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  // Don't set any context headers
  
  requestHeaderForwarder::setRequestHeaders(request);
  
  expect(request.subgraph.headers.contains("uxl-migration-status")).to_be(false);
  expect(request.subgraph.headers.contains("uxl-cart-id")).to_be(false);
});

test("Should not forward headers that are null in context", ||{
  import "request/subgraph/request-header-forwarder" as requestHeaderForwarder;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  request.context["uxl-migration-status"] = ();
  request.context["uxl-cart-id"] = ();
  
  requestHeaderForwarder::setRequestHeaders(request);
  
  expect(request.subgraph.headers.contains("uxl-migration-status")).to_be(false);
  expect(request.subgraph.headers.contains("uxl-cart-id")).to_be(false);
});

test("Should forward headers that are empty strings in context", ||{
  import "request/subgraph/request-header-forwarder" as requestHeaderForwarder;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  request.context["uxl-migration-status"] = "";
  request.context["uxl-cart-id"] = "";
  
  requestHeaderForwarder::setRequestHeaders(request);
  
  // The function forwards empty strings since it only checks for null, not empty strings
  expect(request.subgraph.headers.contains("uxl-migration-status")).to_be(true);
  expect(request.subgraph.headers["uxl-migration-status"]).to_be("");
  expect(request.subgraph.headers.contains("uxl-cart-id")).to_be(true);
  expect(request.subgraph.headers["uxl-cart-id"]).to_be("");
});

test("Should not forward non-forwardable headers from context", ||{
  import "request/subgraph/request-header-forwarder" as requestHeaderForwarder;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  request.context["uxl-migration-status"] = "migrated";
  request.context["uxl-cart-id"] = "cart-12345";
  request.context["non-forwardable-header"] = "should-not-be-forwarded";
  
  requestHeaderForwarder::setRequestHeaders(request);
  
  expect(request.subgraph.headers.contains("uxl-migration-status")).to_be(true);
  expect(request.subgraph.headers.contains("uxl-cart-id")).to_be(true);
  expect(request.subgraph.headers.contains("non-forwardable-header")).to_be(false);
});

test("Should overwrite existing subgraph headers when context has values", ||{
  import "request/subgraph/request-header-forwarder" as requestHeaderForwarder;
  
  let supergraph_request = apollo_mocks::get_supergraph_service_request();
  let request = apollo_mocks::get_subgraph_service_request(supergraph_request);
  
  // Set existing headers in subgraph
  request.subgraph.headers["uxl-migration-status"] = "old-value";
  request.subgraph.headers["uxl-cart-id"] = "old-cart";
  
  // Set new values in context
  request.context["uxl-migration-status"] = "new-migrated";
  request.context["uxl-cart-id"] = "new-cart-123";
  
  requestHeaderForwarder::setRequestHeaders(request);
  
  expect(request.subgraph.headers["uxl-migration-status"]).to_be("new-migrated");
  expect(request.subgraph.headers["uxl-cart-id"]).to_be("new-cart-123");
});
