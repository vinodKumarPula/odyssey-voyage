fn setOperationalResponseHeaders(response) {
    response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains";
    response.headers["X-Content-Type-Options"] = "nosniff";
    response.headers["X-Frame-Options"] = "DENY";
    response.headers["Referrer-Policy"] = "no-referrer";
    response.headers["Content-Security-Policy"] = "default-src 'none'; frame-ancestors 'none'";
    response.headers["Permissions-Policy"] = "none";
}
