terraform {
  backend "s3" {
    bucket       = "terraform-state-638331728031-eu-west-1"
    use_lockfile = true
    # dynamodb_table = "terraform-state-lock"
    key     = "nero's-pizza-infra-test/terraform.tfstate"
    encrypt = true
    region  = "eu-west-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "eu-west-1"
  access_key = var.access_key
  secret_key = var.secret_key
  default_tags {
    tags = {
      Environment = var.env,
      ManagedBy   = "terraform"
      Project     = "neros-pizza-test"
    }
  }
}

locals {
  thresholds = {
    api_5xx_rate_percent   = 5
    api_p99_latency_ms     = 2000
    api_lambda_errors      = 5
    duration_timeout_ratio = 0.8
    queue_age_seconds      = 300
    app_errors             = 5
    anomaly_band_width     = 2
  }
}

module "alerting" {
  source = "../../modules/alerting"
  name_prefix = var.env
  alert_email = var.alert_email
}

module "logging" {
  source = "../../modules/logging"
  name_prefix = var.env
}

module "workload" {
  source = "../../modules/workload"
  name_prefix = var.env
  failure_rate = 0.2
  access_log_group_arn = module.logging.access_log_group_arn
  api_log_group_name = module.logging.api_log_group_name
  worker_log_group_name = module.logging.worker_log_group_name
}

module "synthetic" {
  source = "../../modules/synthetics"
  name_prefix = var.env
  canary_name = "neros-test-canary"
  api_endpoint = module.workload.api_endpoint
  runtime_version = "syn-nodejs-puppeteer-9.1"
  schedule_expression = "rate(5 minutes)"
  timeout_in_seconds = 60
  start_canary = true
  success_retention_days = 2
  failure_retention_days = 7
  artifact_expiration_days = 7
  log_retention_days = 7
}

module "alarms" {
  source = "../../modules/alarms"
  name_prefix = var.env
  critical_topic_arn = module.alerting.critical_topic_arn
  warning_topic_arn = module.alerting.warning_topic_arn
  api_id = module.workload.api_id
  api_stage_name = module.workload.api_stage_name
  api_function_name = module.workload.api_function_name
  api_function_timeout_ms = module.workload.api_function_timeout_ms
  worker_function_name = module.workload.worker_function_name
  worker_function_timeout_ms = module.workload.worker_function_timeout_ms
  queue_name = module.workload.queue_name
  dlq_name = module.workload.dlq_name
  table_name = module.workload.table_name
  metric_names = module.logging.metric_names
  metric_namespace = module.logging.metric_namespace
  emf_namespace = module.logging.metric_namespace
  emf_service_name = "orders"
  thresholds = local.thresholds
  canary_alarm_name = "${module.synthetic.canary_name}-alarm"
  canary_name = module.synthetic.canary_name
}

module "dashboard" {
  source = "../../modules/dashboards"
  name_prefix = var.env
  thresholds  = local.thresholds
  workload   = module.workload
  logging    = module.logging
  alarms     = module.alarms
  synthetics = module.synthetic
}