data "aws_iam_policy" "lambda_basic_exe_policy" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "lambda_sqs_exe_policy" {
  name = "AWSLambdaSQSQueueExecutionRole"
}