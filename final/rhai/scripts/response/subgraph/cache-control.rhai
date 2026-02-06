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

fn queue_cache_control(response) {
  let cache_control = response.headers.values("cache-control").get(0);

  // if a subgraph response is uncacheable, the whole response is uncacheable
  if cache_control == () {
    response.context.cache_control_uncacheable = true;
    return;
  }

  let max_age = get_max_age(cache_control);

  cache_control_restrict(response, max_age);

  handle_cache_scope(response, cache_control);
}

fn queue_client_cache_control(response) {
  if response.context.query_desired_max_age == () {
    return;
  }

  const desired_max_age = response.context.query_desired_max_age;

  cache_control_restrict(response, desired_max_age);
  handle_cache_scope(response, "public");
}

// find the the max-age= part and parse the value into an integer
fn get_max_age(str) {
  let max_age = 0;

  for part in str.split(",") {
    part.remove(" ");

    if part.starts_with("max-age=") {
      let num = part.split("=").get(1);

      if num == () || num == "" {
        break;
      }

      try {
        max_age = num.parse_int();
      } catch (err) {
        log_error(`error parsing max-age from "${str}": ${err}`);
      }
      break;
    }
  }

  max_age
}
