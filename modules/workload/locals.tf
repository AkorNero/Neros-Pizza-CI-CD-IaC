locals {
  api_routes = toset([
    "POST /orders",
    "GET /health",
  ])
  order_worker_mng_policies = [data.aws_iam_policy.lambda_basic_exe_policy, data.aws_iam_policy.lambda_sqs_exe_policy]
}