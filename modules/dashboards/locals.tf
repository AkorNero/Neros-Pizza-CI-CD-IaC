data "aws_region" "current" {}

locals {
  region = data.aws_region.current.name

  names = {
    overview = "${var.name_prefix}-overview"
    pipeline = "${var.name_prefix}-pipeline"
    business = "${var.name_prefix}-business"
  }

  urls = { for k, n in local.names :
    k => "https://${local.region}.console.aws.amazon.com/cloudwatch/home?region=${local.region}#dashboards/dashboard/${n}" }

  # Reusable dimension lists
  api_dims    = ["ApiId", var.workload.api_id, "Stage", var.workload.api_stage_name]
  api_fn_dims = ["FunctionName", var.workload.api_function_name]
  wk_fn_dims  = ["FunctionName", var.workload.worker_function_name]
}