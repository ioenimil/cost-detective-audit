variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "eu-west-1"
}

variable "alert_email" {
  description = "Email address for budget alerts"
  type        = string
}
