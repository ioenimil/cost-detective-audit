variable "aws_region" {
  description = "The AWS region to deploy the state bucket into"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket. Must be globally unique."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Audit"
    Project     = "CostDetective"
    ManagedBy   = "Terraform"
  }
}
