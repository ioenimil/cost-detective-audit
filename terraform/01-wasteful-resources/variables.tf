variable "aws_region" {
  description = "The AWS region to deploy the resources into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "audit-lab"
}
