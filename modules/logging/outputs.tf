# ---------- Log groups ----------
output "api_log_group_name" {
  description = "orders-api Lambda log group name (logging_config.log_group)"
  value       = aws_cloudwatch_log_group.order_api_log_group.name
}

output "worker_log_group_name" {
  description = "orders-worker Lambda log group name (logging_config.log_group)"
  value       = aws_cloudwatch_log_group.order_worker_log_group.name
}

output "access_log_group_arn" {
  description = "API Gateway access log group ARN (stage access_log_settings.destination_arn)"
  value       = aws_cloudwatch_log_group.order_api_access_log_group.arn
}

output "access_log_group_name" {
  description = "API Gateway access log group name"
  value       = aws_cloudwatch_log_group.order_api_access_log_group.name
}

output "api_log_group_arn" {
  description = "orders-api Lambda log group ARN"
  value       = aws_cloudwatch_log_group.order_api_log_group.arn
}

output "worker_log_group_arn" {
  description = "orders-worker Lambda log group ARN"
  value       = aws_cloudwatch_log_group.order_worker_log_group.arn
}

# ---------- Metrics ----------
output "metric_namespace" {
  description = "Namespace used by every metric filter"
  value       = var.metric_namespace
}

output "metric_names" {
  description = "Metric names created by the metric filters"
  value = {
    api_app_errors        = aws_cloudwatch_log_metric_filter.order_api_app_error.metric_transformation[0].name
    api_lambda_timeout    = aws_cloudwatch_log_metric_filter.order_api_lambda_timeout.metric_transformation[0].name
    worker_lambda_timeout = aws_cloudwatch_log_metric_filter.order_worker_lambda_timeout.metric_transformation[0].name
    gateway_5xx           = aws_cloudwatch_log_metric_filter.access_group_gateway_5xx.metric_transformation[0].name
    worker_poison         = aws_cloudwatch_log_metric_filter.order_worker_poison_message.metric_transformation[0].name
    order_value           = aws_cloudwatch_log_metric_filter.order_value.metric_transformation[0].name
  }
}
