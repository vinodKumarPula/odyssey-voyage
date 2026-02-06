import "request/subgraph/subgraph-service" as subgraphRequestService;
import "request/supergraph/supergraph-service" as supergraphRequestService;

import "response/subgraph/subgraph-service" as subgraphResponseService;
import "response/supergraph/supergraph-service" as supergraphResponseService;

print("YESSSS");
fn process_supergraph_request(request) {
  supergraphRequestService::process_request(request);
}

fn process_supergraph_response(response) {
  print("response********* "+ response.body);
  supergraphResponseService::process_response(response);
}

fn supergraph_service(service) {
  // Rhai convention for creating a function pointer
  const request_callback = Fn("process_supergraph_request"); 
  const response_callback = Fn("process_supergraph_response");

  service.map_request(request_callback);
  service.map_response(response_callback);
}

fn process_subgraph_request(request) {
  subgraphRequestService::process_request(request);
}

fn process_subgraph_response(response) {
  subgraphResponseService::process_response(response);
}

fn subgraph_service(service, subgraph) {
  // Rhai convention for creating a function pointer
  const request_callback = Fn("process_subgraph_request"); 
  const response_callback = Fn("process_subgraph_response");

  service.map_request(request_callback);
  service.map_response(response_callback);
}