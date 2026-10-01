# api_id, api_url, stage name, function names, queue names/ARNs, table name
# ---------- API Gateway ----------
output "api_id" {
  description = "HTTP API id (ApiId dimension for API Gateway metrics)"
  value       = aws_apigatewayv2_api.order_api.id
}

output "api_endpoint" {
  description = "Base URL of the API (default execute-api endpoint)"
  value       = aws_apigatewayv2_api.order_api.api_endpoint
}

output "api_execution_arn" {
  description = "Execution ARN, used for Lambda permissions"
  value       = aws_apigatewayv2_api.order_api.execution_arn
}

output "api_stage_name" {
  description = "Stage name (Stage dimension for API Gateway metrics)"
  value       = aws_apigatewayv2_stage.order_api.name
}

output "api_stage_id" {
  description = "Stage id, used by the custom domain API mapping"
  value       = aws_apigatewayv2_stage.order_api.id
}

# ---------- Lambda ----------
output "api_function_name" {
  description = "orders-api function name (FunctionName dimension)"
  value       = aws_lambda_function.order_api.function_name
}

output "api_function_arn" {
  description = "orders-api function ARN"
  value       = aws_lambda_function.order_api.arn
}

output "api_function_timeout_ms" {
  description = "orders-api timeout in ms, for the duration-near-timeout alarm"
  value       = aws_lambda_function.order_api.timeout * 1000
}

output "worker_function_name" {
  description = "orders-worker function name (FunctionName dimension)"
  value       = aws_lambda_function.order_worker.function_name
}

output "worker_function_arn" {
  description = "orders-worker function ARN"
  value       = aws_lambda_function.order_worker.arn
}

output "worker_function_timeout_ms" {
  description = "orders-worker timeout in ms"
  value       = aws_lambda_function.order_worker.timeout * 1000
}

# ---------- SQS ----------
output "queue_name" {
  description = "Main queue name (QueueName dimension)"
  value       = aws_sqs_queue.order_queue.name
}

output "queue_arn" {
  description = "Main queue ARN"
  value       = aws_sqs_queue.order_queue.arn
}

output "queue_url" {
  description = "Main queue URL"
  value       = aws_sqs_queue.order_queue.url
}

output "dlq_name" {
  description = "Dead-letter queue name (QueueName dimension for the DLQ alarm)"
  value       = aws_sqs_queue.dead_letter_queue.name
}

output "dlq_arn" {
  description = "Dead-letter queue ARN"
  value       = aws_sqs_queue.dead_letter_queue.arn
}

output "dlq_url" {
  description = "Dead-letter queue URL, for redrive commands"
  value       = aws_sqs_queue.dead_letter_queue.url
}

# ---------- DynamoDB ----------
output "table_name" {
  description = "Orders table name (TableName dimension)"
  value       = aws_dynamodb_table.order_table.name
}

output "table_arn" {
  description = "Orders table ARN"
  value       = aws_dynamodb_table.order_table.arn
}

# ---------- IAM ----------
output "api_role_arn" {
  description = "Execution role ARN for orders-api"
  value       = aws_iam_role.order_api_role.arn
}

output "worker_role_arn" {
  description = "Execution role ARN for orders-worker"
  value       = aws_iam_role.order_worker_role.arn
}
