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

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "m5.xlarge"
}

variable "ebs_volume_count" {
  description = "Number of EBS volumes to create"
  type        = number
  default     = 2
}

variable "ebs_volume_size" {
  description = "Size of the EBS volumes in GB"
  type        = number
  default     = 50
}

variable "ebs_volume_type" {
  description = "Type of the EBS volumes"
  type        = string
  default     = "gp3"
}
