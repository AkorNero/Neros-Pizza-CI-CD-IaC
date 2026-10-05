locals {
  topics = {
    critical = var.critical_topic_arn
    warning  = var.warning_topic_arn
  }

  static_alarms = merge({
    "dlq-not-empty" = {
      description         = "Messages in DLQ: inspect and redrive"
      namespace           = "AWS/SQS"
      metric_name         = "ApproximateNumberOfMessagesVisible"
      dimensions          = { QueueName = var.dlq_name }
      statistic           = "Maximum"
      period              = 60
      evaluation_periods  = 1
      datapoints_to_alarm = 1
      threshold           = 0
      comparison_operator = "GreaterThanThreshold"
      treat_missing_data  = "notBreaching"
      severity            = "critical"
    }
    "api-lambda-errors" = {
      description         = "Count of Erros in the order api lambda"
      namespace           = "AWS/Lambda"
      metric_name         = "Errors"
      dimensions          = { FunctionName = var.api_function_name }
      statistic           = "Sum"
      period              = 60
      evaluation_periods  = 3
      datapoints_to_alarm = 2
      threshold           = var.thresholds.api_lambda_errors
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      severity            = "warning"
    }
    "worker-lambda-errors" = {
      description         = "Count of Erros in the worker api lambda"
      namespace           = "AWS/Lambda"
      metric_name         = "Errors"
      dimensions          = { FunctionName = var.worker_function_name }
      statistic           = "Sum"
      period              = 60
      evaluation_periods  = 3
      datapoints_to_alarm = 2
      threshold           = var.thresholds.api_lambda_errors
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      severity            = "warning"
    }
    "api-lambda-throttle" = {
      description         = "Count of throttle in the order api lambda"
      namespace           = "AWS/Lambda"
      metric_name         = "Throttles"
      dimensions          = { FunctionName = var.api_function_name }
      statistic           = "Sum"
      period              = 60
      evaluation_periods  = 1
      datapoints_to_alarm = 1
      threshold           = 0
      comparison_operator = "GreaterThanThreshold"
      treat_missing_data  = "notBreaching"
      severity            = "warning"
    }
    "worker-lambda-throttle" = {
      description         = "Count of throttle in the order worker lambda"
      namespace           = "AWS/Lambda"
      metric_name         = "Throttles"
      dimensions          = { FunctionName = var.worker_function_name }
      statistic           = "Sum"
      period              = 60
      evaluation_periods  = 1
      datapoints_to_alarm = 1
      threshold           = 0
      comparison_operator = "GreaterThanThreshold"
      treat_missing_data  = "notBreaching"
      severity            = "warning"
    }
    "queue-falling-behind" = {
      description         = "Oldest message in the orders queue is over 5 minutes old: the worker is falling behind. Check worker errors, throttles and duration."
      namespace           = "AWS/SQS"
      metric_name         = "ApproximateAgeOfOldestMessage"
      dimensions          = { QueueName = var.queue_name }
      statistic           = "Maximum"
      period              = 60
      evaluation_periods  = 3
      datapoints_to_alarm = 3
      threshold           = var.thresholds.queue_age_seconds
      comparison_operator = "GreaterThanThreshold"
      treat_missing_data  = "notBreaching"
      severity            = "warning"
    }
    "app-errors" = {
      description         = "Application ERROR log lines above 5 in 5 min: run the top-errors saved query."
      namespace           = var.metric_namespace
      metric_name         = var.metric_names["api_app_errors"]
      dimensions          = {}
      statistic           = "Sum"
      period              = 300
      evaluation_periods  = 1
      datapoints_to_alarm = 1
      threshold           = 5
      comparison_operator = "GreaterThanOrEqualToThreshold"
      treat_missing_data  = "notBreaching"
      severity            = "warning"
    }
  }, var.canary_alarm_name == null ? {} : { "canary-failing" = {
    description         = "Synthetic canary success below 90% for 10 min: users likely can't place orders. Check the canary run screenshots/logs, then API 5xx and Lambda errors."
    namespace           = "CloudWatchSynthetics"
    metric_name         = "SuccessPercent"
    dimensions          = { CanaryName = var.canary_alarm_name }
    statistic           = "Average"
    period              = 300
    evaluation_periods  = 2
    datapoints_to_alarm = 2
    threshold           = 90
    comparison_operator = "LessThanThreshold"
    treat_missing_data  = "breaching"
    severity            = "page"
  }})

  math_alarms = {
    "dynamodb_errors" = {
      description = "DynamoDB system errors or throttles on PutItem. check AWS Health Dashboard and table capacity."
      severity = "warning"
      treat_missing_data = "notBreaching"
      evaluation_periods = 1
      datapoints_to_alarm = 1
      threshold = 0
      comparison_operator = "GreaterThanThreshold"
      expression = "FILL(m1, 0) + FILL(m2, 0)"
      period = 60
      metrics = {
        m1 = {namespace = "AWS/DynamoDB", name = "SystemErrors",      dims = { TableName = var.table_name, Operation = "PutItem" }, stat = "Sum"}
        m2 = { namespace = "AWS/DynamoDB", name = "ThrottledRequests", dims = { TableName = var.table_name, Operation = "PutItem" }, stat = "Sum" }
      }
    }
    "api_5xx_rate" = {
      description = "API 5xx error rate above ${var.thresholds.api_5xx_rate_percent}% of requests: users are seeing server errors. Check orders-api Lambda errors and the top-errors saved query."
      severity = "page"
      treat_missing_data = "notBreaching"
      evaluation_periods = 5
      datapoints_to_alarm = 3
      threshold = var.thresholds.api_5xx_rate_percent
      comparison_operator = "GreaterThanThreshold"
      expression = "IF(m2 > 0, 100 * m1 / m2, 0)"
      period = 60
      metrics = {
        m1 = {namespace = "AWS/ApiGateway", name = "5xx",      dims = { ApiId = var.api_id , Stage = var.api_stage_name }, stat = "Sum"}
        m2 = { namespace = "AWS/ApiGateway", name = "Count", dims = { ApiId = var.api_id , Stage = var.api_stage_name }, stat = "Sum" }
      }
    }
  }

  percentile_alarm = {
    "api-p99-latency" = {
      description = "API p99 latency above ${var.thresholds.api_p99_latency_ms} ms: the slowest 1% of requests are too slow. Compare Latency vs IntegrationLatency, then run the slowest-requests saved query."
      namespace           = "AWS/ApiGateway"
      metric_name         = "Latency"
      dimensions          = { ApiId = var.api_id , Stage = var.api_stage_name }
      extended_statistic  = "p99"
      period              = 60
      evaluation_periods  = 5
      datapoints_to_alarm = 3
      threshold           = var.thresholds.api_p99_latency_ms
      comparison_operator = "GreaterThanThreshold"
      treat_missing_data  = "notBreaching"
      severity            = "warning"
      evaluate_low_sample_count_percentiles = "ignore"
    }
    "duration-near-timeout" = {
      description = "orders-api p95 duration above ${var.thresholds.duration_timeout_ratio * 100}% of its ${var.api_function_timeout_ms} ms timeout: requests are close to timing out. Check DynamoDB/SQS latency and cold starts."
      namespace           = "AWS/Lambda"
      metric_name         = "Duration"
      dimensions          = { FunctionName = var.api_function_name }
      extended_statistic  = "p95"
      period              = 60
      evaluation_periods  = 5
      datapoints_to_alarm = 3
      threshold           = var.api_function_timeout_ms * var.thresholds.duration_timeout_ratio
      comparison_operator = "GreaterThanThreshold"
      treat_missing_data  = "notBreaching"
      severity            = "warning"
      evaluate_low_sample_count_percentiles = "ignore"
    }
  }
  page_alarm_names = ["api_5xx_rate","canary-failing"]
}