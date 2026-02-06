import "util" as util;
/*
    This function reassigns the content from x-authorization-all to authorization header.
    The reason: For a particular case of passing basic, bearer token at once.
    Akana assigns authorization content to x-authorization-all header. Here we assign it back to
    authorization header for subgraphs.
*/
fn reassignAuthorizationHeader(request) {
    if(
        !util::containsHeader(request, "authorization") && 
        util::containsHeader(request, "x-authorization-all")
    ) {
        request.headers["authorization"] = request.headers["x-authorization-all"];
    }
}
