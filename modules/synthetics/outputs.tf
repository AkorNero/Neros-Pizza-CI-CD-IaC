output "canary_name" {
  description = "Canary name (Canary name for alarm)"
  value       = aws_synthetics_canary.canary.name
}

output "canary_arn" {
  description = "Canary ARN"
  value       = aws_synthetics_canary.canary.arn
}

output "canary_function_arn" {
  description = "ARN of the Lambda the canary runs on (engine_arn)"
  value       = aws_synthetics_canary.canary.engine_arn
}

output "canary_log_group_name" {
  description = "Canary Lambda log group, for dashboards and Logs Insights"
  value       = aws_cloudwatch_log_group.canary.name
}

output "artifacts_bucket_name" {
  description = "S3 bucket holding screenshots, HAR files and run logs"
  value       = aws_s3_bucket.canary_bucket.bucket
}

output "canary_role_arn" {
  description = "Canary execution role ARN"
  value       = aws_iam_role.canary_lambda_role.arn
}