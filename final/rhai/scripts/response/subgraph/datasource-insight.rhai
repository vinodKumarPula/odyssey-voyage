import "util" as util;

fn isDataSourceInsightInProduction() {
    util::getEnv("IS_PRODUCTION","false") == "true";
}

fn populateCacheStore(cacheStore) {
    #{
        age: cacheStore.age,
        name: cacheStore.name,
    };
}

fn populateCacheOptions(cacheOptions) {
    #{
        tags: cacheOptions.tags,
        desiredMaxAge: cacheOptions.desiredMaxAge,
        ttl: cacheOptions.ttl,
        bucket: cacheOptions.bucket,
    };
}
fn populateCache(insightCache) {
    let cache= #{

    };
    if insightCache?.store !=() {
        cache.store = populateCacheStore(insightCache.store);
    }
    if insightCache?.options !=() {
        cache.options = populateCacheOptions(insightCache.options);   
    }
    cache;
}

fn filterAndMaskResponseForProduction(insights) {
    let filteredValues = [];
    for insight in insights {
        let filteredValue = #{
            datasource: insight.datasource,
            type: insight.type,
            requestTiming: insight.requestTiming,
        };
        if insight.cache != () {
            filteredValue.cache = populateCache(insight.cache);
        }
       
        filteredValues.push(filteredValue);
    }
    
    filteredValues
}

fn storeDataSourceInsightsInContext(response) {
    const existingDatasourceInsights = response?.context["datasourceInsights"];
    if response?.body?.extensions?.datasources?.len > 0 {
        let datasources = response.body.extensions.datasources;
            datasources =  if isDataSourceInsightInProduction() { filterAndMaskResponseForProduction(datasources) } else { datasources };

        if datasources?.len > 0 {
            if existingDatasourceInsights?.len >0 {
                datasources += existingDatasourceInsights;
            }
            response.context["datasourceInsights"] = datasources;
        }
    }
}