/** Get the environment configured value or default value */
fn getEnv(envName,defaultValue) {
    try{
        const envValue = env::get(envName);
        return if envValue?.len >0 { envValue } else { defaultValue };
    } catch(err) {
      log_error(`Error in loading env name: ${envName}`);
    }
    return defaultValue;
}

/** Checks whether the request header contains the value */
fn containsHeader(request,headerName) {
  return (request.headers.contains(headerName) && request.headers[headerName]?.len > 0); 
}

/** Joins the array elements with a delimiter*/
fn join(array,delimiter) {
  let returnValue="";
  for element in array {
    returnValue+=element+delimiter;
  }

  if returnValue.ends_with(delimiter) {
    return returnValue.sub_string(0,returnValue.len-delimiter.len);
  }

  return returnValue;
}

fn binarySearch(sortedArray, target) {
  let low = 0;
  let high = sortedArray.len - 1;

  while low <= high {
    let mid = (low + high) / 2;
    if sortedArray[mid] == target {
      return true;
    } else if sortedArray[mid] < target {
      low = mid + 1;
    } else {
      high = mid - 1;
    }
  }

  return false;
}

fn getQueryParameter(request) {
  let uri = `${request.uri}`;
  if uri.contains("?") {
    let parts = uri.split("?");
    if parts.len() > 1 {
        let query = parts[1];
        let params = query.split("&");
        for pair in params {
            if pair.starts_with("op=") {
                let kv = pair.split("=");
                if kv.len() > 1 {
                    return kv[1];
                }
            }
        }
    }
  }
  return ();
}

/**
  List of allowed response headers
*/
fn getAllowedResponseHeaders() {
  [
    "aka",
    "uxl-migration-status",
    "uxl-cart-id"
  ]
}

/**
  List of subgraph response headers to forward to other subgraphs
*/
fn getSubgraphResponseHeadersToForwardToSubgraphs() {
  [
    "uxl-migration-status",
    "uxl-cart-id",
  ]
}
