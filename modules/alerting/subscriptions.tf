resource "aws_sns_topic_subscription" "alert_sub" {
  for_each = aws_sns_topic.alerts
  topic_arn = each.value.arn
  protocol = "email"
  endpoint = var.alert_email
}