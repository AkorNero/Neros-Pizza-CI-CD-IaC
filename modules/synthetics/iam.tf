resource "aws_iam_role" "canary_lambda_role" {
  name = "${var.name_prefix}-canary-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "canary_lambda_role_policy" {
  role = aws_iam_role.canary_lambda_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:PutObject", "s3:GetObject", "s3:GetBucketLocation"]
        Effect   = "Allow"
        Resource = [aws_s3_bucket.canary_bucket.arn, "${aws_s3_bucket.canary_bucket.arn}/*"]
      },
      {
        Action   = ["s3:ListAllMyBuckets"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["cloudwatch:PutMetricData"]
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "CloudWatchSynthetics"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/cwsyn-*"
      }
    ]
  })
}