import "util" as util;

/**
  Validate that the given cacheTag only contains valid characters and it's length is > 0 <= 128
*/
fn validateCacheTagCharacters(cacheTag) {
  if cacheTag == () || cacheTag.len == 0 || cacheTag.len > 128 {
    return false;
  }
  const allowedChars = ["!","#","$","%","&","'","+","-",".","0","1","2","3","4","5","6","7","8","9","^","_","`","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","|","~"];
  for char in cacheTag.chars() {
    if !(util::binarySearch(allowedChars, char)) {
      return false;
    }
  }
  return true;
}

/**
  Sanitize the given array of cache tags by converting each to lower case
  and trimming the leading and trailing whitespace.
*/
fn sanitizeCacheTags(cacheTags) {
  if cacheTags == () || cacheTags.len <= 0 {
    return [];
  }
  let newCacheTags = [];
  for cacheTag in cacheTags {
    let newCacheTag = cacheTag?.to_lower();
    newCacheTag?.trim();
    if validateCacheTagCharacters(newCacheTag) {
      newCacheTags += newCacheTag;
    }
  }
  return newCacheTags;
}

/**
  For each cache tag in a sug-graph response, validate it, sanitize it and
  store it in context if not already there. The aggregated set of cache tags
  from all the sub-graphs will be sent in the final super-graph response.
*/
fn storeCacheTagsInContext(response) {
  let newCacheTagsHeaderValue = response.headers.values("edge-cache-tag").get(0);
  let newCacheTags = sanitizeCacheTags(newCacheTagsHeaderValue?.split(","));
  if newCacheTags.len == 0 {
    return;
  }

  response.context.upsert("cacheTags", |current| {
    let updatedCacheTags = [];
    if current == () {
      updatedCacheTags = [];
    }
    else {
      updatedCacheTags = current;
    };
    for newCacheTag in newCacheTags {
      if !(newCacheTag in updatedCacheTags) {
        updatedCacheTags += newCacheTag;
      }
    }
    return updatedCacheTags;
  });
}
