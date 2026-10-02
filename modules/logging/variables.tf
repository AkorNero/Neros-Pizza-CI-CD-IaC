variable "name_prefix" {
  type        = string
  default     = "neros-pizza-test"
  description = "The prefix of the service's name, value should be of environment"
}

variable "metric_namespace" {
  type = string
  default = "NerosPizza/Orders"
  description = "The namespace for the log metric transforms"
}