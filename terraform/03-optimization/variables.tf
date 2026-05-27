variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "audit-lab"
}

variable "project_name" {
  description = "Project name used for naming and tagging"
  type        = string
  default     = "cost-detective"
}

variable "vpc_name" {
  description = "Name of the VPC for the optimization demo"
  type        = string
  default     = "optimization-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks (must align 1:1 with azs)"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "azs" {
  description = "Availability Zones to spread the ASG and ALB across"
  type        = list(string)
}

variable "on_demand_base_capacity" {
  description = "Absolute number of On-Demand instances kept at all times"
  type        = number
  default     = 1
}

variable "on_demand_percentage_above_base_capacity" {
  description = "Percent of capacity above the On-Demand base that should be On-Demand. 0 = all Spot above the base."
  type        = number
  default     = 0
}

variable "min_size" {
  description = "Minimum ASG size"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum ASG size"
  type        = number
  default     = 6
}

variable "desired_capacity" {
  description = "Desired ASG size at apply time"
  type        = number
  default     = 2
}

variable "target_cpu_utilization" {
  description = "Target average CPU for the ASG scaling policy"
  type        = number
  default     = 50
}
