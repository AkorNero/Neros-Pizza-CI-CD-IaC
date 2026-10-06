output "api_url" {
  description = "Call this to test the API"
  value       = module.workload.api_endpoint
}

output "test_commands" {
  description = "Copy-paste smoke tests (Windows cmd)"
  value = {
    health      = "curl ${module.workload.api_endpoint}/health"
    place_order = "curl -X POST ${module.workload.api_endpoint}/orders -H \"Content-Type: application/json\" -d \"{\\\"amount\\\": 42}\""
    poison      = "curl -X POST ${module.workload.api_endpoint}/orders -H \"Content-Type: application/json\" -d \"{\\\"amount\\\": 1, \\\"poison\\\": true}\""
  }
}

# ---------- Where to look ----------
output "dashboards" {
  description = "Open these first"
  value       = module.dashboard.dashboard_urls
}

output "log_groups" {
  description = "Log groups for Logs Insights / tail"
  value = {
    api    = module.logging.api_log_group_name
    worker = module.logging.worker_log_group_name
    access = module.logging.access_log_group_name
    canary = module.synthetic.canary_log_group_name
  }
}

# ---------- Alerting ----------
output "paging_alarm" {
  description = "The only alarm that pages"
  value       = module.alarms.composite_alarm_name
}

output "sns_topics" {
  description = "Confirm the email subscriptions for these"
  value = {
    critical = module.alerting.critical_topic_arn
    warning  = module.alerting.warning_topic_arn
  }
}

# ---------- Resources ----------
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

output "canary" {
  description = "Synthetic canary"
  value = {
    name             = module.synthetic.canary_name
    artifacts_bucket = module.synthetic.artifacts_bucket_name
  }
}

output "ops_commands" {
  description = "Handy commands"
  value = {
    tail_api_logs = "aws logs tail ${module.logging.api_log_group_name} --follow"
    dlq_redrive   = "aws sqs start-message-move-task --source-arn ${module.workload.dlq_arn}"
    alarm_states  = "aws cloudwatch describe-alarms --alarm-name-prefix ${var.env} --query \"MetricAlarms[].[AlarmName,StateValue]\" --output table"
  }
}