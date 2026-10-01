output "api_url" {
  description = "Call this to test the API"
  value       = module.workload.api_endpoint
}

output "test_commands" {
  description = "Copy-paste smoke tests"
  value = {
    health      = "curl ${module.workload.api_endpoint}/health"
    place_order = "curl -X POST ${module.workload.api_endpoint}/orders -d '{\"amount\": 42}'"
    poison      = "curl -X POST ${module.workload.api_endpoint}/orders -d '{\"amount\": 1, \"poison\": true}'"
  }
}

output "function_names" {
  description = "Lambda function names, for logs and metrics"
  value = {
    api    = module.workload.api_function_name
    worker = module.workload.worker_function_name
  }
}

output "queues" {
  description = "Queue names"
  value = {
    main = module.workload.queue_name
    dlq  = module.workload.dlq_name
  }
}

output "table_name" {
  description = "DynamoDB table name"
  value       = module.workload.table_name
}
