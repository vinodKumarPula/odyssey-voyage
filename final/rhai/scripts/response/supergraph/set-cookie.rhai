
/**
Copy set_cookie_headers from the context to response header
*/
fn copySetCookieResponseHeader(response) {
    if response.context["set_cookie_headers"]?.len > 0 {
        response.headers["set-cookie"] = response.context["set_cookie_headers"];
    }
}