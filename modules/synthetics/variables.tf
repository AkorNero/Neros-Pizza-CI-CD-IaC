# modules/synthetics/variables.tf

variable "name_prefix" {
  description = "Prefix for bucket/role names, e.g. neros-pizza-test"
  type        = string
  default     = "neros-pizza-test"
}

variable "canary_name" {
  description = "Canary name: lowercase letters, digits, - or _, max 21 chars"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-z_-]{1,21}$", var.canary_name))
    error_message = "canary_name must be 1-21 chars of [0-9a-z_-]."
  }
}

variable "api_endpoint" {
  description = "Base URL of the API, passed to the script as API_URL"
  type        = string
}

variable "runtime_version" {
  description = "Synthetics runtime; pick the newest syn-nodejs-puppeteer-* from the AWS runtime list"
  type        = string
  default     = "syn-nodejs-puppeteer-9.1"
}

variable "schedule_expression" {
  description = "How often the canary runs"
  type        = string
  default     = "rate(5 minutes)"
}

variable "timeout_in_seconds" {
  description = "Max run time per execution"
  type        = number
  default     = 60
}

variable "start_canary" {
  description = "Start the canary after creation (set false to pause)"
  type        = bool
  default     = false
}

variable "success_retention_days" {
  description = "Days to keep data for successful runs"
  type        = number
  default     = 2
}

variable "failure_retention_days" {
  description = "Days to keep data for failed runs"
  type        = number
  default     = 7
}

variable "artifact_expiration_days" {
  description = "S3 lifecycle expiry for screenshots/HAR/logs"
  type        = number
  default     = 7
}

variable "log_retention_days" {
  description = "Log retention period for the log group the canary's lambda creates"
  type        = number
  default     = 7
}