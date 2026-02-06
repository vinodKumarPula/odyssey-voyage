test("Should store aka header in context when present in response", ||{
  import "response/subgraph/response-header-forwarder" as responseHeaderForwarder;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["aka"] = "test-aka-value";
  
  responseHeaderForwarder::storeResponseHeadersInContext(response);
  
  expect(response.context.contains("aka")).to_be(true);
  expect(response.context["aka"]).to_be("test-aka-value");
});

test("Should store uxl-migration-status header in context when present in response", ||{
  import "response/subgraph/response-header-forwarder" as responseHeaderForwarder;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["uxl-migration-status"] = "migrated";
  
  responseHeaderForwarder::storeResponseHeadersInContext(response);
  
  expect(response.context.contains("uxl-migration-status")).to_be(true);
  expect(response.context["uxl-migration-status"]).to_be("migrated");
});

test("Should store uxl-cart-id header in context when present in response", ||{
  import "response/subgraph/response-header-forwarder" as responseHeaderForwarder;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["uxl-cart-id"] = "cart-12345";
  
  responseHeaderForwarder::storeResponseHeadersInContext(response);
  
  expect(response.context.contains("uxl-cart-id")).to_be(true);
  expect(response.context["uxl-cart-id"]).to_be("cart-12345");
});

test("Should store multiple allowed headers in context", ||{
  import "response/subgraph/response-header-forwarder" as responseHeaderForwarder;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["aka"] = "test-aka";
  response.headers["uxl-migration-status"] = "migrated";
  response.headers["uxl-cart-id"] = "cart-67890";
  
  responseHeaderForwarder::storeResponseHeadersInContext(response);
  
  expect(response.context.contains("aka")).to_be(true);
  expect(response.context["aka"]).to_be("test-aka");
  expect(response.context.contains("uxl-migration-status")).to_be(true);
  expect(response.context["uxl-migration-status"]).to_be("migrated");
  expect(response.context.contains("uxl-cart-id")).to_be(true);
  expect(response.context["uxl-cart-id"]).to_be("cart-67890");
});

test("Should not store headers that are not in allowed list", ||{
  import "response/subgraph/response-header-forwarder" as responseHeaderForwarder;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["aka"] = "test-aka";
  response.headers["uxl-migration-status"] = "migrated";
  response.headers["non-allowed-header"] = "should-not-be-stored";
  response.headers["another-non-allowed"] = "also-should-not-be-stored";
  
  responseHeaderForwarder::storeResponseHeadersInContext(response);
  
  expect(response.context.contains("aka")).to_be(true);
  expect(response.context.contains("uxl-migration-status")).to_be(true);
  expect(response.context.contains("non-allowed-header")).to_be(false);
  expect(response.context.contains("another-non-allowed")).to_be(false);
});

test("Should not store headers when they are not present in response", ||{
  import "response/subgraph/response-header-forwarder" as responseHeaderForwarder;
  
  let response = apollo_mocks::get_subgraph_service_response();
  // Don't set any headers
  
  responseHeaderForwarder::storeResponseHeadersInContext(response);
  
  expect(response.context.contains("aka")).to_be(false);
  expect(response.context.contains("uxl-migration-status")).to_be(false);
  expect(response.context.contains("uxl-cart-id")).to_be(false);
});

test("Should overwrite existing context headers when response has new values", ||{
  import "response/subgraph/response-header-forwarder" as responseHeaderForwarder;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["aka"] = "old-aka-value";
  response.context["uxl-migration-status"] = "old-migration-status";
  
  response.headers["aka"] = "new-aka-value";
  response.headers["uxl-migration-status"] = "new-migration-status";
  
  responseHeaderForwarder::storeResponseHeadersInContext(response);
  
  expect(response.context["aka"]).to_be("new-aka-value");
  expect(response.context["uxl-migration-status"]).to_be("new-migration-status");
});

test("Should handle empty header values", ||{
  import "response/subgraph/response-header-forwarder" as responseHeaderForwarder;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["aka"] = "";
  response.headers["uxl-migration-status"] = "";
  
  responseHeaderForwarder::storeResponseHeadersInContext(response);
  
  expect(response.context.contains("aka")).to_be(true);
  expect(response.context["aka"]).to_be("");
  expect(response.context.contains("uxl-migration-status")).to_be(true);
  expect(response.context["uxl-migration-status"]).to_be("");
});

test("Should handle headers with special characters", ||{
  import "response/subgraph/response-header-forwarder" as responseHeaderForwarder;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["aka"] = "test-value-with-special-chars!@#$%";
  response.headers["uxl-migration-status"] = "migrated-with-dashes-and_underscores";
  
  responseHeaderForwarder::storeResponseHeadersInContext(response);
  
  expect(response.context["aka"]).to_be("test-value-with-special-chars!@#$%");
  expect(response.context["uxl-migration-status"]).to_be("migrated-with-dashes-and_underscores");
});

test("Should handle headers with numeric values", ||{
  import "response/subgraph/response-header-forwarder" as responseHeaderForwarder;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["aka"] = "12345";
  response.headers["uxl-cart-id"] = "67890";
  
  responseHeaderForwarder::storeResponseHeadersInContext(response);
  
  expect(response.context["aka"]).to_be("12345");
  expect(response.context["uxl-cart-id"]).to_be("67890");
});

test("Should handle mixed allowed and non-allowed headers", ||{
  import "response/subgraph/response-header-forwarder" as responseHeaderForwarder;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["aka"] = "allowed-value";
  response.headers["uxl-migration-status"] = "migrated";
  response.headers["content-type"] = "application/json";
  response.headers["authorization"] = "Bearer token";
  response.headers["uxl-cart-id"] = "cart-123";
  
  responseHeaderForwarder::storeResponseHeadersInContext(response);
  
  expect(response.context.contains("aka")).to_be(true);
  expect(response.context.contains("uxl-migration-status")).to_be(true);
  expect(response.context.contains("uxl-cart-id")).to_be(true);
  expect(response.context.contains("content-type")).to_be(false);
  expect(response.context.contains("authorization")).to_be(false);
});

test("Should handle case-sensitive header names", ||{
  import "response/subgraph/response-header-forwarder" as responseHeaderForwarder;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["AKA"] = "uppercase-aka";
  response.headers["aka"] = "lowercase-aka";
  response.headers["Uxl-Migration-Status"] = "mixed-case";
  
  responseHeaderForwarder::storeResponseHeadersInContext(response);
  
  // Should only store the exact case matches
  expect(response.context.contains("AKA")).to_be(false);
  expect(response.context.contains("aka")).to_be(true);
  expect(response.context["aka"]).to_be("lowercase-aka");
  expect(response.context.contains("Uxl-Migration-Status")).to_be(false);
});
