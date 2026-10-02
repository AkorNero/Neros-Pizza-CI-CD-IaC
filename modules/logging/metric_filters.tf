resource "aws_cloudwatch_log_metric_filter" "order_api_app_error" {
  name = "${var.name_prefix}-app-errors"
  log_group_name = aws_cloudwatch_log_group.order_api_log_group.name
  pattern = "{$.level=\"ERROR\"}"
  metric_transformation {
    name = "OrderAPIApplicationError"
    namespace = var.metric_namespace
    value = "1"
    default_value = "0"
    unit = "Count"
  }
}

resource "aws_cloudwatch_log_metric_filter" "order_api_lambda_timeout" {
  name = "${var.name_prefix}-lambda-timeout"
  log_group_name = aws_cloudwatch_log_group.order_api_log_group.name
  pattern = "Task timed out"
  metric_transformation {
    name = "OrderAPILambdaTimeout"
    namespace = var.metric_namespace
    value = "1"
    default_value = "0"
    unit = "Count"
  }
}

resource "aws_cloudwatch_log_metric_filter" "order_worker_lambda_timeout" {
  name = "${var.name_prefix}-worker-lambda-timeout"
  log_group_name = aws_cloudwatch_log_group.order_worker_log_group.name
  pattern = "Task timed out"
  metric_transformation {
    name = "OrderWorkerLambdaTimeout"
    namespace = var.metric_namespace
    value = "1"
    default_value = "0"
    unit = "Count"
  }
}

resource "aws_cloudwatch_log_metric_filter" "access_group_gateway_5xx" {
  name = "${var.name_prefix}-access-group-gateway-5xx"
  log_group_name = aws_cloudwatch_log_group.order_api_access_log_group.name
  pattern = "{$.status >= 500}"
  metric_transformation {
    name = "OrderGateway5XX"
    namespace = var.metric_namespace
    value = "1"
    default_value = "0"
    unit = "Count"
  }
}

resource "aws_cloudwatch_log_metric_filter" "order_worker_poison_message" {
  name = "${var.name_prefix}-order-worker-poison-message"
  log_group_name = aws_cloudwatch_log_group.order_worker_log_group.name
  pattern = "{$.level = \"ERROR\" && $.reason = \"poison\"}"
  metric_transformation {
    name = "OrderWorkerPoison"
    namespace = var.metric_namespace
    value = "1"
    default_value = "0"
    unit = "Count"
  }
}

resource "aws_cloudwatch_log_metric_filter" "order_value" {
  name = "${var.name_prefix}-order-value"
  log_group_name = aws_cloudwatch_log_group.order_api_log_group.name
  pattern = "{$.event = \"order_placed\"}"
  metric_transformation {
    name = "OrderValue"
    namespace = var.metric_namespace
    value = "$.amount"
    dimensions = {
      Route = "$.route"
    }
  }
}