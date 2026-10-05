resource "aws_kms_key" "topic_enc_key" {
  description = "Used to encrypt the sns topics"
  enable_key_rotation = true
  deletion_window_in_days = 7
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "topic-enc-key-default"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchAlarmsToUseKey"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ]
        Resource = "*" # means for this resource only as a key policy is attached to single key
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "topic_enc_key_alias" {
  name="alias/${var.name_prefix}-alert"
  target_key_id = aws_kms_key.topic_enc_key.key_id # names must start with alias/ and alias/aws/sns or aws managed keys cant be accessed by cloudwatch
}