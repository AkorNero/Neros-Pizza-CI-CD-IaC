resource "aws_iam_role" "order_api_role" {
  name = "${var.name_prefix}-order-api-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.name_prefix}-*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "order_worker_role" {
  name = "${var.name_prefix}-order-worker-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.name_prefix}-*"
          }
        }
      }
    ]
  })
}

locals {
  order_worker_mng_policies = [data.aws_iam_policy.lambda_basic_exe_policy, data.aws_iam_policy.lambda_sqs_exe_policy]
}

resource "aws_iam_role_policy_attachment" "order_api_role_managed_policies" {
  role       = aws_iam_role.order_api_role.name
  policy_arn = data.aws_iam_policy.lambda_basic_exe_policy.arn
}

resource "aws_iam_role_policy" "order_api_role_add_policies" {
  role = aws_iam_role.order_api_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "WriteOrders"
        Action   = ["dynamodb:PutItem"]
        Effect   = "Allow"
        Resource = [aws_dynamodb_table.order_table.arn]
      },
      {
        Sid      = "PublishOrderEvents"
        Action   = ["sqs:SendMessage"]
        Effect   = "Allow"
        Resource = [aws_sqs_queue.order_queue.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "order_worker_role_managed_policies" {
  count      = length(local.order_worker_mng_policies)
  role       = aws_iam_role.order_worker_role.name
  policy_arn = local.order_worker_mng_policies[count.index].arn
}