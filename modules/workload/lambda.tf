data "archive_file" "order_api_archive" {
  type        = "zip"
  source_dir  = "${path.root}/../../app/api"
  output_path = "${path.root}/.build/order-api.zip"
}

data "archive_file" "order_worker_archive" {
  type        = "zip"
  source_dir  = "${path.root}/../../app/worker"
  output_path = "${path.root}/.build/order-worker.zip"
}

resource "aws_lambda_function" "order_api" {
  function_name    = "${var.name_prefix}-order-api-function"
  role             = aws_iam_role.order_api_role.arn
  runtime          = "python3.13"
  handler          = "handler.handler" # file handler.py, function handler
  filename         = data.archive_file.order_api_archive.output_path
  source_code_hash = data.archive_file.order_api_archive.output_base64sha256
  timeout          = var.api_timeout_seconds
  environment {
    variables = {
      TABLE_NAME       = aws_dynamodb_table.order_table.name
      QUEUE_URL        = aws_sqs_queue.order_queue.url
      SERVICE_NAME     = "orders"
      FAILURE_RATE     = tostring(var.failure_rate)
      EXTRA_LATENCY_MS = tostring(var.extra_latency_ms)
    }
  }

  logging_config {
    log_format = "Text"
    log_group = var.api_log_group_name
  }
}

resource "aws_lambda_function" "order_worker" {
  function_name    = "${var.name_prefix}-order-worker-function"
  role             = aws_iam_role.order_worker_role.arn
  runtime          = "python3.12"
  handler          = "handler.handler" # file handler.py, function handler
  filename         = data.archive_file.order_worker_archive.output_path
  source_code_hash = data.archive_file.order_worker_archive.output_base64sha256
  timeout          = var.worker_timeout_seconds
  environment {
    variables = {
      SERVICE_NAME = "orders"
    }
  }

  logging_config {
    log_format = "Text"
    log_group = var.worker_log_group_name
  }
}

resource "aws_lambda_event_source_mapping" "order_queue_poller" {
  function_name           = aws_lambda_function.order_worker.function_name
  event_source_arn        = aws_sqs_queue.order_queue.arn
  batch_size              = 10
  function_response_types = ["ReportBatchItemFailures"]
}