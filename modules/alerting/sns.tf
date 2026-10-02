locals {
  alert_topics = {
    critical = "Neros Pizza CRITICAL"
    warning  = "Neros Pizza warning"
  }
}

resource "aws_sns_topic" "alerts" {
  for_each          = local.alert_topics
  name              = "${var.name_prefix}-${each.key}"
  display_name      = each.value
  kms_master_key_id = aws_kms_key.topic_enc_key.arn
}

resource "aws_sns_topic_policy" "alert_policy" {
  for_each = aws_sns_topic.alerts
  arn = each.value.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid = "AllowCloudWatchAlarms"
      Principal = {
        Service = "cloudwatch.amazonaws.com"
      }
      Action = "sns:Publish"
      Effect = "Allow"
      Resource = each.value.arn
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        },
        ArnLike = {
          "aws:SourceArn" = "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:*"
        }
      }
    }]
  })
}