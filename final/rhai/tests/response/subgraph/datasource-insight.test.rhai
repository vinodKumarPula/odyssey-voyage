test("Should return false when not in production", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  const result = datasourceInsight::isDataSourceInsightInProduction();
  
  expect(result).to_be(false);
});

test("Should populate cache store with age and name", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let cacheStore = #{
    age: 300,
    name: "test-cache"
  };
  
  const result = datasourceInsight::populateCacheStore(cacheStore);
  
  expect(result.age).to_be(300);
  expect(result.name).to_be("test-cache");
});

test("Should populate cache options with all properties", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let cacheOptions = #{
    tags: ["tag1", "tag2"],
    desiredMaxAge: 600,
    ttl: 1200,
    bucket: "test-bucket"
  };
  
  const result = datasourceInsight::populateCacheOptions(cacheOptions);
  
  expect(result.tags.len()).to_be(2);
  expect(result.tags[0]).to_be("tag1");
  expect(result.tags[1]).to_be("tag2");
  expect(result.desiredMaxAge).to_be(600);
  expect(result.ttl).to_be(1200);
  expect(result.bucket).to_be("test-bucket");
});

test("Should populate cache with store and options", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let insightCache = #{
    store: #{
      age: 300,
      name: "test-cache"
    },
    options: #{
      tags: ["tag1"],
      desiredMaxAge: 600,
      ttl: 1200,
      bucket: "test-bucket"
    }
  };
  
  let result = datasourceInsight::populateCache(insightCache);
  
  expect(result.store.age).to_be(300);
  expect(result.store.name).to_be("test-cache");
  expect(result.options.tags.len()).to_be(1);
  expect(result.options.tags[0]).to_be("tag1");
  expect(result.options.desiredMaxAge).to_be(600);
});

test("Should populate cache with only store", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let insightCache = #{
    store: #{
      age: 300,
      name: "test-cache"
    }
  };
  
  let result = datasourceInsight::populateCache(insightCache);
  
  expect(result.store.age).to_be(300);
  expect(result.store.name).to_be("test-cache");
});

test("Should populate cache with only options", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let insightCache = #{
    options: #{
      tags: ["tag1"],
      desiredMaxAge: 600,
      ttl: 1200,
      bucket: "test-bucket"
    }
  };
  
  let result = datasourceInsight::populateCache(insightCache);
  
  expect(result.options.tags.len()).to_be(1);
  expect(result.options.tags[0]).to_be("tag1");
  expect(result.options.desiredMaxAge).to_be(600);
});

test("Should populate cache with null store and options", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let insightCache = #{
    store: (),
    options: ()
  };
  
  let result = datasourceInsight::populateCache(insightCache);
  
  // Should return an empty object
  expect(result.len()).to_be(0);
});

test("Should filter and mask response for production", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let insights = [#{
    datasource: "test-datasource",
    type: "database",
    requestTiming: 150,
    cache: #{
      store: #{
        age: 300,
        name: "test-cache"
      },
      options: #{
        tags: ["tag1"],
        desiredMaxAge: 600,
        ttl: 1200,
        bucket: "test-bucket"
      }
    },
    sensitiveData: "should-be-filtered"
  }];
  
  let result = datasourceInsight::filterAndMaskResponseForProduction(insights);
  
  expect(result.len()).to_be(1);
  expect(result[0].datasource).to_be("test-datasource");
  expect(result[0].type).to_be("database");
  expect(result[0].requestTiming).to_be(150);
  expect(result[0].cache.store.age).to_be(300);
});

test("Should filter and mask response without cache", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let insights = [#{
    datasource: "test-datasource",
    type: "database",
    requestTiming: 150,
    sensitiveData: "should-be-filtered"
  }];
  
  let result = datasourceInsight::filterAndMaskResponseForProduction(insights);
  
  expect(result.len()).to_be(1);
  expect(result[0].datasource).to_be("test-datasource");
  expect(result[0].type).to_be("database");
  expect(result[0].requestTiming).to_be(150);
});

test("Should filter and mask multiple insights", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let insights = [
    #{
      datasource: "datasource1",
      type: "database",
      requestTiming: 100,
      sensitiveData: "filtered1"
    },
    #{
      datasource: "datasource2",
      type: "api",
      requestTiming: 200,
      cache: #{
        store: #{
          age: 300,
          name: "cache2"
        }
      },
      sensitiveData: "filtered2"
    }
  ];
  
  let result = datasourceInsight::filterAndMaskResponseForProduction(insights);
  
  expect(result.len()).to_be(2);
  expect(result[0].datasource).to_be("datasource1");
  expect(result[1].datasource).to_be("datasource2");
  expect(result[1].cache.store.age).to_be(300);
});

test("Should store datasource insights in context when present", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.body.extensions.datasources = [#{
    datasource: "test-datasource",
    type: "database",
    requestTiming: 150
  }];
  
  datasourceInsight::storeDataSourceInsightsInContext(response);
  
  expect(response.context.contains("datasourceInsights")).to_be(true);
  expect(response.context["datasourceInsights"].len()).to_be(1);
  expect(response.context["datasourceInsights"][0].datasource).to_be("test-datasource");
});

test("Should not store datasource insights when not present", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let response = apollo_mocks::get_subgraph_service_response();
  // Don't set datasources
  
  datasourceInsight::storeDataSourceInsightsInContext(response);
  
  expect(response.context.contains("datasourceInsights")).to_be(false);
});

test("Should not store datasource insights when empty", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.body.extensions.datasources = [];
  
  datasourceInsight::storeDataSourceInsightsInContext(response);
  
  expect(response.context.contains("datasourceInsights")).to_be(false);
});

test("Should append new insights to existing ones", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["datasourceInsights"] = [#{
    datasource: "existing-datasource",
    type: "database",
    requestTiming: 100
  }];
  response.body.extensions.datasources = [#{
    datasource: "new-datasource",
    type: "api",
    requestTiming: 200
  }];
  
  datasourceInsight::storeDataSourceInsightsInContext(response);
  
  expect(response.context["datasourceInsights"].len()).to_be(2);
  expect(response.context["datasourceInsights"][0].datasource).to_be("new-datasource");
  expect(response.context["datasourceInsights"][1].datasource).to_be("existing-datasource");
});

test("Should handle null existing insights", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["datasourceInsights"] = ();
  response.body.extensions.datasources = [#{
    datasource: "test-datasource",
    type: "database",
    requestTiming: 150
  }];
  
  datasourceInsight::storeDataSourceInsightsInContext(response);
  
  expect(response.context["datasourceInsights"].len()).to_be(1);
  expect(response.context["datasourceInsights"][0].datasource).to_be("test-datasource");
});

test("Should handle empty existing insights", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let response = apollo_mocks::get_subgraph_service_response();
  response.context["datasourceInsights"] = [];
  response.body.extensions.datasources = [#{
    datasource: "test-datasource",
    type: "database",
    requestTiming: 150
  }];
  
  datasourceInsight::storeDataSourceInsightsInContext(response);
  
  expect(response.context["datasourceInsights"].len()).to_be(1);
  expect(response.context["datasourceInsights"][0].datasource).to_be("test-datasource");
});

test("Should handle missing extensions and body", ||{
  import "response/subgraph/datasource-insight" as datasourceInsight;
  
  let response = apollo_mocks::get_subgraph_service_response();
  // Don't set extensions.datasources and body
  
  datasourceInsight::storeDataSourceInsightsInContext(response);
  
  expect(response.context.contains("datasourceInsights")).to_be(false);
});
