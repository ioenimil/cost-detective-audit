variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "audit-lab"
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "waste-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "The public subnets CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
}
