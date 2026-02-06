
fn copyDatasourceInsightToResponse(response){
    if response.context["datasourceInsights"]?.len > 0 {
        response.body.extensions.datasources = response.context["datasourceInsights"];
    }
}
