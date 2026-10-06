output "static_alarm_arns" {
  description = "Static alarms, key => ARN"
  value       = { for k, a in aws_cloudwatch_metric_alarm.static : k => a.arn }
}

output "math_alarm_arns" {
  description = "Metric math alarms, key => ARN"
  value       = { for k, a in aws_cloudwatch_metric_alarm.math : k => a.arn }
}

output "percentile_alarm_arns" {
  description = "Percentile alarms, key => ARN"
  value       = { for k, a in aws_cloudwatch_metric_alarm.percentile : k => a.arn }
}

output "anomaly_alarm_arn" {
  description = "Orders-dropped anomaly alarm ARN"
  value       = aws_cloudwatch_metric_alarm.anomaly_order_placed.arn
}

output "composite_alarm_name" {
  description = "The only paging alarm"
  value       = aws_cloudwatch_composite_alarm.comp_alarm.alarm_name
}

output "composite_alarm_arn" {
  description = "Composite alarm ARN"
  value       = aws_cloudwatch_composite_alarm.comp_alarm.arn
}

# One flat list for the dashboard alarm-status widget
output "all_alarm_arns" {
  description = "Every alarm ARN, composite first"
  value = concat(
    [aws_cloudwatch_composite_alarm.comp_alarm.arn],
    values(aws_cloudwatch_metric_alarm.static)[*].arn,
    values(aws_cloudwatch_metric_alarm.math)[*].arn,
    values(aws_cloudwatch_metric_alarm.percentile)[*].arn,
    [aws_cloudwatch_metric_alarm.anomaly_order_placed.arn],
  )
}