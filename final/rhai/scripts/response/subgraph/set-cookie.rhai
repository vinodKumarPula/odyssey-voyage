
/**
Keep the set-cookie response header in the context
*/
fn storeSubgraphResponseSetCookieHeaderInContext(response) {

    if response.headers.values("set-cookie")?.len > 0 {
        if response.context["set_cookie_headers"] == () {
          response.context.set_cookie_headers = []
        }

        response.context.set_cookie_headers += response.headers.values("set-cookie");
    }
}