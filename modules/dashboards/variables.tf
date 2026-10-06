variable "name_prefix" {
  description = "Prefix for dashboard names, e.g. neros-pizza-test"
  type        = string
  default = "neros-pizza-test"
}

variable "thresholds" {
  description = "Same object the alarms module uses, so graph lines match alarm thresholds"
  type = object({
    api_5xx_rate_percent   = number
    api_p99_latency_ms     = number
    duration_timeout_ratio = number
    queue_age_seconds      = number
    anomaly_band_width     = number
  })
}

variable "emf_namespace" {
  description = "Namespace of the EMF business metrics (OrdersPlaced)"
  type        = string
  default     = "NerosPizza/Orders"
}

variable "emf_service_name" {
  description = "Service dimension value on the EMF metrics"
  type        = string
  default     = "orders"
}

# ---------- Module outputs passed as objects ----------
variable "workload" {
  description = "module.workload"
  type = object({
    api_id                     = string
    api_stage_name             = string
    api_function_name          = string
    api_function_timeout_ms    = number
    worker_function_name       = string
    worker_function_timeout_ms = number
    queue_name                 = string
    dlq_name                   = string
  })
}

variable "logging" {
  description = "module.logging"
  type = object({
    api_log_group_name    = string
    worker_log_group_name = string
    access_log_group_name = string
    metric_namespace      = string
    metric_names          = map(string)
  })
}

variable "alarms" {
  description = "module.alarms"
  type = object({
    all_alarm_arns = list(string)
  })
}

variable "synthetics" {
  description = "module.synthetics"
  type = object({
    canary_name           = string
    canary_log_group_name = string
  })
}