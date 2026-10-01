# alert_email, env, service_name, failure_rate (number, 0–1), extra_latency_ms, thresholds (map)

variable "alert_email" {
  sensitive   = true
  type        = string
  description = "The email you want to subscribe to the sns topic for alerts"
}

variable "env" {
  type        = string
  description = "The environment you are deploying the infrastructure for"
  default     = "test"
}

variable "access_key" {
  sensitive = true
  type      = string
}

variable "secret_key" {
  sensitive = true
  type      = string
}