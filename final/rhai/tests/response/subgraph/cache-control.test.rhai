test("Should set max_age when context is empty", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_subgraph_service_response();
  
  cacheControl::cache_control_restrict(response, 300);
  
  expect(response.context["cache_control_max_age"]).to_be(300);
});

test("Should use smaller max_age when current is larger", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["cache_control_max_age"] = 600;
  
  cacheControl::cache_control_restrict(response, 300);
  
  expect(response.context["cache_control_max_age"]).to_be(300);
});

test("Should keep current max_age when new is larger", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["cache_control_max_age"] = 300;
  
  cacheControl::cache_control_restrict(response, 600);
  
  expect(response.context["cache_control_max_age"]).to_be(300);
});

test("Should keep current max_age when new is equal", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["cache_control_max_age"] = 300;
  
  cacheControl::cache_control_restrict(response, 300);
  
  expect(response.context["cache_control_max_age"]).to_be(300);
});

test("Should set scope to public when cache_control contains public", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_subgraph_service_response();
  
  cacheControl::handle_cache_scope(response, "public, max-age=300");
  
  expect(response.context["cache_control_scope"]).to_be("public");
});

test("Should set scope to private when cache_control does not contain public", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_subgraph_service_response();
  
  cacheControl::handle_cache_scope(response, "private, max-age=300");
  
  expect(response.context["cache_control_scope"]).to_be("private");
});

test("Should set scope to private when cache_control is empty", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_subgraph_service_response();
  
  cacheControl::handle_cache_scope(response, "");
  
  expect(response.context["cache_control_scope"]).to_be("private");
});

test("Should keep private scope when current is private and new is public", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["cache_control_scope"] = "private";
  
  cacheControl::handle_cache_scope(response, "public, max-age=300");
  
  expect(response.context["cache_control_scope"]).to_be("private");
});

test("Should set scope to private when current is public and new is private", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["cache_control_scope"] = "public";
  
  cacheControl::handle_cache_scope(response, "private, max-age=300");
  
  expect(response.context["cache_control_scope"]).to_be("private");
});

test("Should set uncacheable when cache-control header is missing", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_subgraph_service_response();
  // Don't set cache-control header
  
  cacheControl::queue_cache_control(response);
  
  expect(response.context["cache_control_uncacheable"]).to_be(true);
});

test("Should process cache-control header with max-age", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["cache-control"] = "public, max-age=300";
  
  cacheControl::queue_cache_control(response);
  
  expect(response.context["cache_control_max_age"]).to_be(300);
  expect(response.context["cache_control_scope"]).to_be("public");
  expect(response.context.contains("cache_control_uncacheable")).to_be(false);
});

test("Should process cache-control header with private scope", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["cache-control"] = "private, max-age=600";
  
  cacheControl::queue_cache_control(response);
  
  expect(response.context["cache_control_max_age"]).to_be(600);
  expect(response.context["cache_control_scope"]).to_be("private");
});

test("Should not process client cache control when query_desired_max_age is missing", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_subgraph_service_response();
  // Don't set query_desired_max_age
  
  cacheControl::queue_client_cache_control(response);
  
  expect(response.context.contains("cache_control_max_age")).to_be(false);
  expect(response.context.contains("cache_control_scope")).to_be(false);
});

test("Should process client cache control when query_desired_max_age is present", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["query_desired_max_age"] = 1200;
  
  cacheControl::queue_client_cache_control(response);
  
  expect(response.context["cache_control_max_age"]).to_be(1200);
  expect(response.context["cache_control_scope"]).to_be("public");
});

test("Should parse max-age from simple cache-control string", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  const maxAge = cacheControl::get_max_age("max-age=300");
  
  expect(maxAge).to_be(300);
});

test("Should parse max-age from complex cache-control string", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  const maxAge = cacheControl::get_max_age("public, max-age=600, must-revalidate");
  
  expect(maxAge).to_be(600);
});

test("Should parse max-age from cache-control string with spaces", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  const maxAge = cacheControl::get_max_age("public, max-age = 900, must-revalidate");
  
  expect(maxAge).to_be(900);
});

test("Should return 0 when max-age is not found", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  const maxAge = cacheControl::get_max_age("public, no-cache");
  
  expect(maxAge).to_be(0);
});

test("Should return 0 when max-age is empty", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  const maxAge = cacheControl::get_max_age("public, max-age=");
  
  expect(maxAge).to_be(0);
});

test("Should return 0 when max-age is invalid", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  const maxAge = cacheControl::get_max_age("public, max-age=invalid");
  
  expect(maxAge).to_be(0);
});

test("Should return 0 when cache-control string is empty", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  const maxAge = cacheControl::get_max_age("");
  
  expect(maxAge).to_be(0);
});

test("Should handle multiple max-age values and use the first one", ||{
  import "response/subgraph/cache-control" as cacheControl;
  
  const maxAge = cacheControl::get_max_age("max-age=300, max-age=600");
  
  expect(maxAge).to_be(300);
});
