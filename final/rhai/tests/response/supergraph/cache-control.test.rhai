test("Should set max_age when context is empty", ||{
  import "response/supergraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_supergraph_service_response();
  
  cacheControl::cache_control_restrict(response, 300);
  
  expect(response.context["cache_control_max_age"]).to_be(300);
});

test("Should use smaller max_age when current is larger", ||{
  import "response/supergraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_supergraph_service_response();
  response.context["cache_control_max_age"] = 600;
  
  cacheControl::cache_control_restrict(response, 300);
  
  expect(response.context["cache_control_max_age"]).to_be(300);
});

test("Should keep current max_age when new is larger", ||{
  import "response/supergraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_supergraph_service_response();
  response.context["cache_control_max_age"] = 300;
  
  cacheControl::cache_control_restrict(response, 600);
  
  expect(response.context["cache_control_max_age"]).to_be(300);
});

test("Should keep current max_age when new is equal", ||{
  import "response/supergraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_supergraph_service_response();
  response.context["cache_control_max_age"] = 300;
  
  cacheControl::cache_control_restrict(response, 300);
  
  expect(response.context["cache_control_max_age"]).to_be(300);
});

test("Should set scope to public when cache_control contains public", ||{
  import "response/supergraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_supergraph_service_response();
  
  cacheControl::handle_cache_scope(response, "public, max-age=300");
  
  expect(response.context["cache_control_scope"]).to_be("public");
});

test("Should set scope to private when cache_control does not contain public", ||{
  import "response/supergraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_supergraph_service_response();
  
  cacheControl::handle_cache_scope(response, "private, max-age=300");
  
  expect(response.context["cache_control_scope"]).to_be("private");
});

test("Should set scope to private when cache_control is empty", ||{
  import "response/supergraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_supergraph_service_response();
  
  cacheControl::handle_cache_scope(response, "");
  
  expect(response.context["cache_control_scope"]).to_be("private");
});

test("Should keep private scope when current is private and new is public", ||{
  import "response/supergraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_supergraph_service_response();
  response.context["cache_control_scope"] = "private";
  
  cacheControl::handle_cache_scope(response, "public, max-age=300");
  
  expect(response.context["cache_control_scope"]).to_be("private");
});

test("Should set scope to private when current is public and new is private", ||{
  import "response/supergraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_supergraph_service_response();
  response.context["cache_control_scope"] = "public";
  
  cacheControl::handle_cache_scope(response, "private, max-age=300");
  
  expect(response.context["cache_control_scope"]).to_be("private");
});

test("Should not process client cache control when query_desired_max_age is missing", ||{
  import "response/supergraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_supergraph_service_response();
  // Don't set query_desired_max_age
  
  cacheControl::queue_client_cache_control(response);
  
  expect(response.context.contains("cache_control_max_age")).to_be(false);
  expect(response.context.contains("cache_control_scope")).to_be(false);
});

test("Should process client cache control when query_desired_max_age is present", ||{
  import "response/supergraph/cache-control" as cacheControl;
  
  let response = apollo_mocks::get_supergraph_service_response();
  response.context["query_desired_max_age"] = 1200;
  
  cacheControl::queue_client_cache_control(response);
  
  expect(response.context["cache_control_max_age"]).to_be(1200);
  expect(response.context["cache_control_scope"]).to_be("public");
});

//The following tests are commented out because the response.body is not built in the rhai-test framework in get_supergraph_service_response()

// test("Should set cache-control header with max-age and scope when conditions are met", ||{
//   import "response/supergraph/cache-control" as cacheControl;
  
//   let response = apollo_mocks::get_supergraph_service_response();
//   response.context["cache_control_uncacheable"] = false;
//   response.context["cache_control_max_age"] = 300;
//   response.context["cache_control_scope"] = "public";
//   response.body.errors = [];
  
//   cacheControl::resolve_cache_control(response);
  
//   expect(response.headers["cache-control"]).to_be("max-age=300, public");
// });

// test("Should set no-store when uncacheable is true", ||{
//   import "response/supergraph/cache-control" as cacheControl;
  
//   let response = apollo_mocks::get_supergraph_service_response();
//   response.context["cache_control_uncacheable"] = true;
//   response.context["cache_control_max_age"] = 300;
//   response.context["cache_control_scope"] = "public";
//   response.body.errors = [];
  
//   cacheControl::resolve_cache_control(response);
  
//   expect(response.headers["cache-control"]).to_be("no-store");
// });

// test("Should set no-store when max_age is null", ||{
//   import "response/supergraph/cache-control" as cacheControl;
  
//   let response = apollo_mocks::get_supergraph_service_response();
//   response.context["cache_control_uncacheable"] = false;
//   response.context["cache_control_max_age"] = ();
//   response.context["cache_control_scope"] = "public";
//   response.body.errors = [];
  
//   cacheControl::resolve_cache_control(response);
  
//   expect(response.headers["cache-control"]).to_be("no-store");
// });

// test("Should set no-store when max_age is 0", ||{
//   import "response/supergraph/cache-control" as cacheControl;
  
//   let response = apollo_mocks::get_supergraph_service_response();
//   response.context["cache_control_uncacheable"] = false;
//   response.context["cache_control_max_age"] = 0;
//   response.context["cache_control_scope"] = "public";
//   response.body.errors = [];
  
//   cacheControl::resolve_cache_control(response);
  
//   expect(response.headers["cache-control"]).to_be("no-store");
// });

// test("Should set no-store when scope is null", ||{
//   import "response/supergraph/cache-control" as cacheControl;
  
//   let response = apollo_mocks::get_supergraph_service_response();
//   response.context["cache_control_uncacheable"] = false;
//   response.context["cache_control_max_age"] = 300;
//   response.context["cache_control_scope"] = ();
//   response.body.errors = [];
  
//   cacheControl::resolve_cache_control(response);
  
//   expect(response.headers["cache-control"]).to_be("no-store");
// });

// test("Should set no-store when errors are present", ||{
//   import "response/supergraph/cache-control" as cacheControl;
  
//   let response = apollo_mocks::get_supergraph_service_response();
//   response.context["cache_control_uncacheable"] = false;
//   response.context["cache_control_max_age"] = 300;
//   response.context["cache_control_scope"] = "public";
//   response.body.errors = [#{message: "Test error"}];
  
//   cacheControl::resolve_cache_control(response);
  
//   expect(response.headers["cache-control"]).to_be("no-store");
// });

// test("Should set cache-control header with private scope", ||{
//   import "response/supergraph/cache-control" as cacheControl;
  
//   let response = apollo_mocks::get_supergraph_service_response();
//   response.context["cache_control_uncacheable"] = false;
//   response.context["cache_control_max_age"] = 600;
//   response.context["cache_control_scope"] = "private";
//   response.body.errors = [];
  
//   cacheControl::resolve_cache_control(response);
  
//   expect(response.headers["cache-control"]).to_be("max-age=600, private");
// });

// test("Should process client cache control and then resolve cache control", ||{
//   import "response/supergraph/cache-control" as cacheControl;
  
//   let response = apollo_mocks::get_supergraph_service_response();
//   response.context["query_desired_max_age"] = 900;
//   response.context["cache_control_uncacheable"] = false;
//   response.body.errors = [];
  
//   cacheControl::resolve_cache_control(response);
  
//   expect(response.context["cache_control_max_age"]).to_be(900);
//   expect(response.context["cache_control_scope"]).to_be("public");
//   expect(response.headers["cache-control"]).to_be("max-age=900, public");
// });

// test("Should handle missing body errors gracefully", ||{
//   import "response/supergraph/cache-control" as cacheControl;
  
//   let response = apollo_mocks::get_supergraph_service_response();
//   response.context["cache_control_uncacheable"] = false;
//   response.context["cache_control_max_age"] = 300;
//   response.context["cache_control_scope"] = "public";
//   // Don't set body.errors
  
//   cacheControl::resolve_cache_control(response);
  
//   expect(response.headers["cache-control"]).to_be("max-age=300, public");
// });

// test("Should handle null body gracefully", ||{
//   import "response/supergraph/cache-control" as cacheControl;
  
//   let response = apollo_mocks::get_supergraph_service_response();
//   response.context["cache_control_uncacheable"] = false;
//   response.context["cache_control_max_age"] = 300;
//   response.context["cache_control_scope"] = "public";
//   response.body = ();
  
//   cacheControl::resolve_cache_control(response);
  
//   expect(response.headers["cache-control"]).to_be("max-age=300, public");
// });
