resource "aws_synthetics_canary" "canary" {
  name                 = var.canary_name
  artifact_s3_location = "s3://${aws_s3_bucket.canary_bucket.bucket}"
  execution_role_arn   = aws_iam_role.canary_lambda_role.arn
  handler              = "index.handler"
  zip_file             = "${path.root}/.build/canary.zip"
  runtime_version      = var.runtime_version
  schedule {
    expression = var.schedule_expression
  }
  start_canary = var.start_canary
  run_config {
    timeout_in_seconds = var.timeout_in_seconds
    environment_variables = {
      "API_URL" = var.api_endpoint
    }
  }
  success_retention_period = var.success_retention_days
  failure_retention_period = var.failure_retention_days
  delete_lambda            = true
}