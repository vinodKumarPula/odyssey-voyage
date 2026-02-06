test("Should validate cache tag with valid characters", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  const result = cacheTags::validateCacheTagCharacters("valid-tag_123");
  
  expect(result).to_be(true);
});

test("Should validate cache tag with all allowed special characters", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  const result = cacheTags::validateCacheTagCharacters("tested!#$%&'+-.^_`|~");
  
  expect(result).to_be(true);
});

test("should reject cache tag with invalid characters", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  const result = cacheTags::validateCacheTagCharacters("tested,@");
  
  expect(result).to_be(false);
});

test("Should reject cache tag that is null", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  const result = cacheTags::validateCacheTagCharacters(());
  
  expect(result).to_be(false);
});

test("Should reject cache tag that is empty string", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  const result = cacheTags::validateCacheTagCharacters("");
  
  expect(result).to_be(false);
});

test("Should reject cache tag that is too long", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  // Create a string longer than 128 characters
  let longTag = "";
  for i in range(0, 130) {
    longTag += "a";
  }
  
  const result = cacheTags::validateCacheTagCharacters(longTag);
  
  expect(result).to_be(false);
});

test("Should reject cache tag with invalid characters", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  const result = cacheTags::validateCacheTagCharacters("invalid@tag");
  
  expect(result).to_be(false);
});

test("Should reject cache tag with spaces", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  const result = cacheTags::validateCacheTagCharacters("tag with spaces");
  
  expect(result).to_be(false);
});

test("Should reject cache tag with uppercase letters", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  const result = cacheTags::validateCacheTagCharacters("UPPERCASE");
  
  expect(result).to_be(false);
});

test("Should accept cache tag with exactly 128 characters", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  // Create a string with exactly 128 characters
  let tag128 = "";
  for i in range(0, 128) {
    tag128 += "a";
  }
  
  const result = cacheTags::validateCacheTagCharacters(tag128);
  
  expect(result).to_be(true);
});

test("Should sanitize cache tags array with valid tags", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  const result = cacheTags::sanitizeCacheTags(["TAG1", " Tag2 ", "tag3"]);
  
  expect(result.len()).to_be(3);
  expect(result[0]).to_be("tag1");
  expect(result[1]).to_be("tag2");
  expect(result[2]).to_be("tag3");
});

test("Should sanitize cache tags array with mixed valid and invalid tags", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  const result = cacheTags::sanitizeCacheTags(["valid-tag", "invalid@tag", "another-valid"]);
  
  expect(result.len()).to_be(2);
  expect(result[0]).to_be("valid-tag");
  expect(result[1]).to_be("another-valid");
});

test("Should return empty array when cache tags is null", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  const result = cacheTags::sanitizeCacheTags(());
  
  expect(result.len()).to_be(0);
});

test("Should return empty array when cache tags is empty", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  const result = cacheTags::sanitizeCacheTags([]);
  
  expect(result.len()).to_be(0);
});

test("Should filter out invalid tags during sanitization", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  const result = cacheTags::sanitizeCacheTags(["", "valid", "invalid@tag", "another-valid"]);
  
  expect(result.len()).to_be(2);
  expect(result[0]).to_be("valid");
  expect(result[1]).to_be("another-valid");
});

test("Should store cache tags in context when header is present", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["edge-cache-tag"] = "tag1,tag2,tag3";
  
  cacheTags::storeCacheTagsInContext(response);
  
  expect(response.context.contains("cacheTags")).to_be(true);
  expect(response.context["cacheTags"].len()).to_be(3);
  expect(response.context["cacheTags"][0]).to_be("tag1");
  expect(response.context["cacheTags"][1]).to_be("tag2");
  expect(response.context["cacheTags"][2]).to_be("tag3");
});

test("Should not store cache tags when header is missing", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  let response = apollo_mocks::get_subgraph_service_response();
  // Don't set edge-cache-tag header
  
  cacheTags::storeCacheTagsInContext(response);
  
  expect(response.context.contains("cacheTags")).to_be(false);
});

test("Should not store cache tags when header is empty", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["edge-cache-tag"] = "";
  
  cacheTags::storeCacheTagsInContext(response);
  
  expect(response.context.contains("cacheTags")).to_be(false);
});

test("Should append new cache tags to existing ones", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["cacheTags"] = ["existing-tag"];
  response.headers["edge-cache-tag"] = "new-tag1,new-tag2";
  
  cacheTags::storeCacheTagsInContext(response);
  
  expect(response.context["cacheTags"].len()).to_be(3);
  expect(response.context["cacheTags"][0]).to_be("existing-tag");
  expect(response.context["cacheTags"][1]).to_be("new-tag1");
  expect(response.context["cacheTags"][2]).to_be("new-tag2");
});

test("Should not duplicate existing cache tags", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["cacheTags"] = ["existing-tag", "another-tag"];
  response.headers["edge-cache-tag"] = "existing-tag,new-tag";
  
  cacheTags::storeCacheTagsInContext(response);
  
  expect(response.context["cacheTags"].len()).to_be(3);
  expect(response.context["cacheTags"][0]).to_be("existing-tag");
  expect(response.context["cacheTags"][1]).to_be("another-tag");
  expect(response.context["cacheTags"][2]).to_be("new-tag");
});

test("Should sanitize cache tags before storing in context", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["edge-cache-tag"] = "TAG1, Tag2 ,invalid@tag,valid-tag";
  
  cacheTags::storeCacheTagsInContext(response);
  
  expect(response.context["cacheTags"].len()).to_be(3);
  expect(response.context["cacheTags"][0]).to_be("tag1");
  expect(response.context["cacheTags"][1]).to_be("tag2");
  expect(response.context["cacheTags"][2]).to_be("valid-tag");
});

test("Should handle cache tags with spaces and special characters", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["edge-cache-tag"] = "tag-with-dash,tag_with_underscore,tag.with.dots";
  
  cacheTags::storeCacheTagsInContext(response);
  
  expect(response.context["cacheTags"].len()).to_be(3);
  expect(response.context["cacheTags"][0]).to_be("tag-with-dash");
  expect(response.context["cacheTags"][1]).to_be("tag_with_underscore");
  expect(response.context["cacheTags"][2]).to_be("tag.with.dots");
});

test("Should handle single cache tag", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["edge-cache-tag"] = "single-tag";
  
  cacheTags::storeCacheTagsInContext(response);
  
  expect(response.context["cacheTags"].len()).to_be(1);
  expect(response.context["cacheTags"][0]).to_be("single-tag");
});

test("Should handle cache tags with numbers", ||{
  import "response/subgraph/cache-tags" as cacheTags;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.headers["edge-cache-tag"] = "tag123,456tag,tag-789";
  
  cacheTags::storeCacheTagsInContext(response);
  
  expect(response.context["cacheTags"].len()).to_be(3);
  expect(response.context["cacheTags"][0]).to_be("tag123");
  expect(response.context["cacheTags"][1]).to_be("456tag");
  expect(response.context["cacheTags"][2]).to_be("tag-789");
});
