
fn cache_control_restrict(response,max_age) {
  // use the smallest max age
  response.context.upsert("cache_control_max_age", |current| {
    if current == () {
      max_age
    } else if max_age < current {
      max_age
    } else {
      current
    }
  });
}

fn handle_cache_scope(response, cache_control) {
  let scope = if cache_control.contains("public") {
    "public"
  } else {
    "private"
  };

  response.context.upsert("cache_control_scope", |current| {
    if current == "private" || scope == "private" {
      "private"
    } else {
      scope
    }
  });
}

fn queue_client_cache_control(response) {
  if response.context.query_desired_max_age == () {
    return;
  }

  const desired_max_age = response.context.query_desired_max_age;

  cache_control_restrict(response, desired_max_age);
  handle_cache_scope(response, "public");
}

fn resolve_cache_control(response) {
  // We add the client's desired max age if it exists.
  queue_client_cache_control(response);
  // attach the cache-control header if enough data is available
  // Note the check for is_primary() to support deferred response headers
  // https://www.apollographql.com/docs/router/customizations/rhai-api/#response-interface
  let uncacheable = response.context.cache_control_uncacheable;
  let max_age = response.context.cache_control_max_age;
  let scope = response.context.cache_control_scope;
  let errors = response?.body?.errors?.len() > 0;
  
  if uncacheable != true && max_age != () && max_age > 0 && scope != () && !errors {
    response.headers["cache-control"] = `max-age=${max_age}, ${scope}`;
  }
  else {
    response.headers["cache-control"] = "no-store";
  }
}
