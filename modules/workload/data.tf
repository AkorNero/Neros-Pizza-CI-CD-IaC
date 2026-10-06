data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy" "lambda_basic_exe_policy" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "lambda_sqs_exe_policy" {
  name = "AWSLambdaSQSQueueExecutionRole"
}