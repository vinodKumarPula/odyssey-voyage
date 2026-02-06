test("Should assign the value from x-authorization-all to authorization header if authorization header is not present", ||{
  let request = apollo_mocks::get_supergraph_service_request();
  import "request/supergraph/modify-headers" as modifyHeaders;

  request.headers["x-authorization-all"] = "Basic test";
  modifyHeaders::reassignAuthorizationHeader(request);
  expect(request.headers["authorization"]).to_be("Basic test");
});

test("Should assign comma separated values from x-authorization-all to authorization header if authorization header is not present", ||{
  let request = apollo_mocks::get_supergraph_service_request();
  import "request/supergraph/modify-headers" as modifyHeaders;

  request.headers["x-authorization-all"] = "Basic test,Bearer test2";
  modifyHeaders::reassignAuthorizationHeader(request);
  expect(request.headers["authorization"]).to_be("Basic test,Bearer test2");
});

test("Should assign comma separated values from x-authorization-all to authorization header if authorization header is present but empty", ||{
  let request = apollo_mocks::get_supergraph_service_request();
  import "request/supergraph/modify-headers" as modifyHeaders;

  request.headers["x-authorization-all"] = "Basic test,Bearer test2";
  request.headers["authorization"] = "";
  modifyHeaders::reassignAuthorizationHeader(request);
  expect(request.headers["authorization"]).to_be("Basic test,Bearer test2");
});

test("Should not assign the value from x-authorization-all to authorization header if authorization header is present", ||{
  let request = apollo_mocks::get_supergraph_service_request();
  import "request/supergraph/modify-headers" as modifyHeaders;

  request.headers["x-authorization-all"] = "Basic test";
  request.headers["authorization"] = "Basic test2";
  modifyHeaders::reassignAuthorizationHeader(request);
  expect(request.headers["authorization"]).to_be("Basic test2");
});
