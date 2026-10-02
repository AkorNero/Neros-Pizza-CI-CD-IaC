# modules/alerting/outputs.tf

output "critical_topic_arn" {
  description = "SNS topic for paging alerts (composite alarm, DLQ alarm)"
  value       = aws_sns_topic.alerts["critical"].arn
}

output "warning_topic_arn" {
  description = "SNS topic for non-urgent alerts"
  value       = aws_sns_topic.alerts["warning"].arn
}

output "topic_arns" {
  description = "All alert topic ARNs, keyed by severity"
  value       = { for k, t in aws_sns_topic.alerts : k => t.arn }
}

output "kms_key_arn" {
  description = "KMS key used to encrypt the alert topics"
  value       = aws_kms_key.topic_enc_key.arn
}

output "kms_alias_name" {
  description = "Friendly alias of the alert KMS key"
  value       = aws_kms_alias.topic_enc_key_alias.name
}