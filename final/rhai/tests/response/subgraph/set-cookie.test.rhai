test("Should store single set-cookie header in context when present", ||{
  import "response/subgraph/set-cookie" as setCookie;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["set-cookie"] = "sessionId=abc123; Path=/; HttpOnly";
  
  setCookie::storeSubgraphResponseSetCookieHeaderInContext(response);
  
  expect(response.context.contains("set_cookie_headers")).to_be(true);
  expect(response.context["set_cookie_headers"].len()).to_be(1);
  expect(response.context["set_cookie_headers"][0]).to_be("sessionId=abc123; Path=/; HttpOnly");
});

test("Should store multiple set-cookie headers in context when present", ||{
  import "response/subgraph/set-cookie" as setCookie;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["set-cookie"] = ["sessionId=abc123; Path=/; HttpOnly", "theme=dark; Path=/; Max-Age=3600"];
  
  setCookie::storeSubgraphResponseSetCookieHeaderInContext(response);
  
  expect(response.context.contains("set_cookie_headers")).to_be(true);
  expect(response.context["set_cookie_headers"].len()).to_be(2);
  expect(response.context["set_cookie_headers"][0]).to_be("sessionId=abc123; Path=/; HttpOnly");
  expect(response.context["set_cookie_headers"][1]).to_be("theme=dark; Path=/; Max-Age=3600");
});

test("Should append to existing set-cookie headers in context", ||{
  import "response/subgraph/set-cookie" as setCookie;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["set_cookie_headers"] = ["existingCookie=value1; Path=/"];
  response.headers["set-cookie"] = "newCookie=value2; Path=/; HttpOnly";
  
  setCookie::storeSubgraphResponseSetCookieHeaderInContext(response);
  
  expect(response.context["set_cookie_headers"].len()).to_be(2);
  expect(response.context["set_cookie_headers"][0]).to_be("existingCookie=value1; Path=/");
  expect(response.context["set_cookie_headers"][1]).to_be("newCookie=value2; Path=/; HttpOnly");
});

test("Should append multiple cookies to existing set-cookie headers in context", ||{
  import "response/subgraph/set-cookie" as setCookie;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["set_cookie_headers"] = ["existingCookie=value1; Path=/"];
  response.headers["set-cookie"] = ["newCookie1=value2; Path=/; HttpOnly", "newCookie2=value3; Path=/; Secure"];
  
  setCookie::storeSubgraphResponseSetCookieHeaderInContext(response);
  
  expect(response.context["set_cookie_headers"].len()).to_be(3);
  expect(response.context["set_cookie_headers"][0]).to_be("existingCookie=value1; Path=/");
  expect(response.context["set_cookie_headers"][1]).to_be("newCookie1=value2; Path=/; HttpOnly");
  expect(response.context["set_cookie_headers"][2]).to_be("newCookie2=value3; Path=/; Secure");
});

test("Should not store set-cookie headers when not present in response", ||{
  import "response/subgraph/set-cookie" as setCookie;
  
  let response = apollo_mocks::get_subgraph_service_response();
  // Don't set set-cookie header
  
  setCookie::storeSubgraphResponseSetCookieHeaderInContext(response);
  
  expect(response.context.contains("set_cookie_headers")).to_be(false);
});

test("Should not store set-cookie headers when empty", ||{
  import "response/subgraph/set-cookie" as setCookie;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["set-cookie"] = [];
  
  setCookie::storeSubgraphResponseSetCookieHeaderInContext(response);
  
  expect(response.context.contains("set_cookie_headers")).to_be(false);
});

test("Should initialize empty array when context has null set_cookie_headers", ||{
  import "response/subgraph/set-cookie" as setCookie;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["set_cookie_headers"] = ();
  response.headers["set-cookie"] = "sessionId=abc123; Path=/; HttpOnly";
  
  setCookie::storeSubgraphResponseSetCookieHeaderInContext(response);
  
  expect(response.context.contains("set_cookie_headers")).to_be(true);
  expect(response.context["set_cookie_headers"].len()).to_be(1);
  expect(response.context["set_cookie_headers"][0]).to_be("sessionId=abc123; Path=/; HttpOnly");
});

test("Should handle cookies with complex attributes", ||{
  import "response/subgraph/set-cookie" as setCookie;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["set-cookie"] = "sessionId=abc123; Path=/api; Domain=example.com; HttpOnly; Secure; SameSite=Strict; Max-Age=3600";
  
  setCookie::storeSubgraphResponseSetCookieHeaderInContext(response);
  
  expect(response.context["set_cookie_headers"].len()).to_be(1);
  expect(response.context["set_cookie_headers"][0]).to_be("sessionId=abc123; Path=/api; Domain=example.com; HttpOnly; Secure; SameSite=Strict; Max-Age=3600");
});

test("Should handle cookies with special characters in values", ||{
  import "response/subgraph/set-cookie" as setCookie;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["set-cookie"] = "userPref=theme%3Ddark%26lang%3Den; Path=/; HttpOnly";
  
  setCookie::storeSubgraphResponseSetCookieHeaderInContext(response);
  
  expect(response.context["set_cookie_headers"].len()).to_be(1);
  expect(response.context["set_cookie_headers"][0]).to_be("userPref=theme%3Ddark%26lang%3Den; Path=/; HttpOnly");
});

test("Should handle cookies with empty values", ||{
  import "response/subgraph/set-cookie" as setCookie;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["set-cookie"] = "emptyCookie=; Path=/; HttpOnly";
  
  setCookie::storeSubgraphResponseSetCookieHeaderInContext(response);
  
  expect(response.context["set_cookie_headers"].len()).to_be(1);
  expect(response.context["set_cookie_headers"][0]).to_be("emptyCookie=; Path=/; HttpOnly");
});

test("Should handle cookies with expiration dates", ||{
  import "response/subgraph/set-cookie" as setCookie;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["set-cookie"] = "persistentCookie=value123; Path=/; Expires=Wed, 09 Jun 2024 10:18:14 GMT";
  
  setCookie::storeSubgraphResponseSetCookieHeaderInContext(response);
  
  expect(response.context["set_cookie_headers"].len()).to_be(1);
  expect(response.context["set_cookie_headers"][0]).to_be("persistentCookie=value123; Path=/; Expires=Wed, 09 Jun 2024 10:18:14 GMT");
});

test("Should handle multiple cookies with different attributes", ||{
  import "response/subgraph/set-cookie" as setCookie;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["set-cookie"] = [
    "sessionId=abc123; Path=/; HttpOnly; Secure",
    "theme=dark; Path=/; Max-Age=3600",
    "language=en; Path=/; Domain=example.com; SameSite=Lax"
  ];
  
  setCookie::storeSubgraphResponseSetCookieHeaderInContext(response);
  
  expect(response.context["set_cookie_headers"].len()).to_be(3);
  expect(response.context["set_cookie_headers"][0]).to_be("sessionId=abc123; Path=/; HttpOnly; Secure");
  expect(response.context["set_cookie_headers"][1]).to_be("theme=dark; Path=/; Max-Age=3600");
  expect(response.context["set_cookie_headers"][2]).to_be("language=en; Path=/; Domain=example.com; SameSite=Lax");
});

test("Should handle case-sensitive set-cookie header name", ||{
  import "response/subgraph/set-cookie" as setCookie;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["Set-Cookie"] = "sessionId=abc123; Path=/; HttpOnly";
  response.headers["set-cookie"] = "lowercaseCookie=value; Path=/";
  
  setCookie::storeSubgraphResponseSetCookieHeaderInContext(response);
  
  // Should only process the lowercase "set-cookie" header
  expect(response.context["set_cookie_headers"].len()).to_be(1);
  expect(response.context["set_cookie_headers"][0]).to_be("lowercaseCookie=value; Path=/");
});
