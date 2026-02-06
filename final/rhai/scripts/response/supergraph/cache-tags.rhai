import "util" as util;

/**
  Send all the sanitized and de-duped cache tags from each of the sub-graph responses
  in the final super-graph response. Use the first 128 cache tags then sort the array
  before combining into a final result.
*/
fn setCacheTagHeaderInSupergraphResponse(response) {
  let cacheTags = response.context["cacheTags"];
  if cacheTags == () || cacheTags.len == 0 {
    return
  }

  cacheTags = cacheTags.extract(0..128);
  cacheTags.sort();

  response.headers["edge-cache-tag"] = util::join(cacheTags, ",");
}
