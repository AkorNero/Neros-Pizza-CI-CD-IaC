variable "name_prefix" {
  type        = string
  default     = "neros-pizza-test"
  description = "The prefix of the service's name, value should be of environment"
}

variable "alert_email" {
  type = string
  description = "The email that you want the to subscribe to alerts from sns"
}