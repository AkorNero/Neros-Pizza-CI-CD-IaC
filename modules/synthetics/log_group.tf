locals {
  canary_fn_name = split(":", aws_synthetics_canary.canary.engine_arn)[6]
}

resource "aws_cloudwatch_log_group" "canary" {
  name              = "/aws/lambda/${local.canary_fn_name}"
  retention_in_days = var.log_retention_days
}