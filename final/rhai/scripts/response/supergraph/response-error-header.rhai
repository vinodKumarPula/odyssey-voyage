fn setUxlResponseErrorHeaderInSuperGraphResponse(response) {
  let errorHeader = response.context["responseErrorHeaderValues"];
  if errorHeader == () || errorHeader?.len == 0 {
    return;
  }

  response.headers["uxl-response-error"] = util::join(errorHeader, ",");
}
