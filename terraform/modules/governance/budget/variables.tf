variable "alert_email" {
  description = "Email address for budget alerts"
  type        = string
}

variable "limit_amount" {
  description = "Total budget limit in USD"
  type        = string
  default     = "15.0"
}
