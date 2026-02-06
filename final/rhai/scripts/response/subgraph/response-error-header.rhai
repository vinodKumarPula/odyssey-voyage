
fn storeResponseErrorHeaderInContext(response) {
  let errorHeader = response?.headers?.values("uxl-response-error")?.get(0);
  if errorHeader == () {
    return;
  }

  let errorHeaderValues = errorHeader.split(",");
  if errorHeaderValues.len == 0 {
    return;
  }

  response.context.upsert("responseErrorHeaderValues", |current| {
    let updatedErrorHeaderValues = [];
    if current == () {
      updatedErrorHeaderValues = [];
    } else {
      updatedErrorHeaderValues = current;
    };
    for newErrorHeaderValue in errorHeaderValues {
      if !(newErrorHeaderValue in updatedErrorHeaderValues) {
        updatedErrorHeaderValues += newErrorHeaderValue;
      }
    }
    return updatedErrorHeaderValues;
  });
}
