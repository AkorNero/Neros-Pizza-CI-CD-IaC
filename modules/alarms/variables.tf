# ---------- General ----------
variable "name_prefix" {
  description = "Prefix for every alarm name, e.g. neros-pizza-test"
  type        = string
  default = "neros-pizza-test"
}

# ---------- Alerting (from module.alerting) ----------
variable "critical_topic_arn" {
  description = "SNS topic for paging alerts (composite, DLQ)"
  type        = string
}

variable "warning_topic_arn" {
  description = "SNS topic for non-urgent alerts"
  type        = string
}

# ---------- API Gateway (from module.workload) ----------
variable "api_id" {
  description = "HTTP API id (ApiId dimension)"
  type        = string
}

variable "api_stage_name" {
  description = "API stage name (Stage dimension), usually $default"
  type        = string
}

# ---------- Lambda (from module.workload) ----------
variable "api_function_name" {
  description = "orders-api function name (FunctionName dimension)"
  type        = string
}

variable "worker_function_name" {
  description = "orders-worker function name (FunctionName dimension)"
  type        = string
}

variable "api_function_timeout_ms" {
  description = "orders-api timeout in ms, for the duration-near-timeout alarm"
  type        = number
}

variable "worker_function_timeout_ms" {
  description = "orders-worker timeout in ms"
  type        = number
}

# ---------- SQS & DynamoDB (from module.workload) ----------
variable "queue_name" {
  description = "Main queue name (QueueName dimension)"
  type        = string
}

variable "dlq_name" {
  description = "Dead-letter queue name (QueueName dimension)"
  type        = string
}

variable "table_name" {
  description = "Orders table name (TableName dimension)"
  type        = string
}

# ---------- Log-derived metrics (from module.logging) ----------
variable "metric_namespace" {
  description = "Namespace used by the metric filters"
  type        = string
}

variable "metric_names" {
  description = "Metric filter metric names, keyed as in module.logging's metric_names output"
  type        = map(string)
}

# ---------- EMF metrics (from handler.py) ----------
variable "emf_namespace" {
  description = "Namespace in the handler's EMF line (OrdersPlaced lives here)"
  type        = string
  default     = "NerosPizza/Orders"
}

variable "emf_service_name" {
  description = "Value of the EMF 'Service' dimension (SERVICE_NAME env var)"
  type        = string
  default     = "orders"
}

# ---------- Phase 7 (optional until the canary exists) ----------
variable "canary_alarm_name" {
  description = "Name of the canary-failing alarm to add to the composite"
  type        = string
  default     = null
}

# ---------- Tunable thresholds (override in terraform.tfvars) ----------
variable "thresholds" {
  description = "Alarm thresholds, overridable without editing resources"
  type = object({
    api_5xx_rate_percent   = optional(number, 5)
    api_p99_latency_ms     = optional(number, 2000)
    api_lambda_errors      = optional(number, 5)
    duration_timeout_ratio = optional(number, 0.8)
    queue_age_seconds      = optional(number, 300)
    app_errors             = optional(number, 5)
    anomaly_band_width     = optional(number, 2)
  })
  default = {}
}