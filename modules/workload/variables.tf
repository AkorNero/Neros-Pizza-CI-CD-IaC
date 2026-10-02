# name_prefix, failure_rate, extra_latency_ms, api_timeout, log group ARNs/names, source dirs

variable "name_prefix" {
  type        = string
  default     = "neros-pizza-test"
  description = "The prefix of the service's name, value should be of environment"
}

variable "failure_rate" {
  description = "Share of POST /orders requests that fail on purpose (0 to 1)"
  type        = number
  default     = 0

  validation {
    condition     = var.failure_rate >= 0 && var.failure_rate <= 1
    error_message = "failure_rate must be between 0 and 1."
  }
}

variable "extra_latency_ms" {
  description = "Delay added to every order request, in milliseconds"
  type        = number
  default     = 0
}

variable "api_timeout_seconds" {
  description = "Timeout for the orders-api Lambda"
  type        = number
  default     = 3
}

variable "worker_timeout_seconds" {
  description = "Timeout for the orders-worker Lambda"
  type        = number
  default     = 10
}

variable "api_log_group_name" {
  description = "Log group for the orders-api Lambda"
  type        = string
}

variable "worker_log_group_name" {
  description = "Log group for the orders-worker Lambda"
  type        = string
}

variable "access_log_group_arn" {
  description = "Log group ARN for API Gateway access logs"
  type        = string
}