test("Should perform binary search correctly", ||{
  const sortedArray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  import "util" as util;

  // Should return true if the target is found
  const search1 = util::binarySearch(sortedArray, 5);
  expect(search1).to_be(true);

  // Should return false if the target is not found
  const search2 = util::binarySearch(sortedArray, 11);
  expect(search2).to_be(false);
});

test("Should perform util::containsHeader correctly", ||{
  let request = apollo_mocks::get_supergraph_service_request();
  import "util" as util;

  // Should return true if the header is found
  request.headers["test"] = "test";
  const search1 = util::containsHeader(request, "test");
  expect(search1).to_be(true);

  // Should return false if the header is not found
  const search2 = util::containsHeader(request, "test2");
  expect(search2).to_be(false);

  // Should return false if the header is empty
  request.headers["test3"] = "";
  const search3 = util::containsHeader(request, "test3");
  expect(search3).to_be(false);
});

test("Should perform util::getEnv correctly", ||{
  import "util" as util;
  const env1 = util::getEnv("TEST_ENV", "test");
  expect(env1).to_be("test");
});

test("Should perform util::join correctly", ||{
  import "util" as util;

  const joined1 = util::join(["test", "test2", "test3"], ",");
  expect(joined1).to_be("test,test2,test3");

  const joined2 = util::join(["test", "test2", "test3"], "|");
  expect(joined2).to_be("test|test2|test3");

  const joined3 = util::join(["test", "test2", "test3"], "");
  expect(joined3).to_be("testtest2test3");

  expect(joined1).not().to_be("test,test2,test3,");
  expect(joined3).not().to_be("test,test2,test3");

});
