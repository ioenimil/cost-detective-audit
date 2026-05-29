variable "project_name" {
  description = "Project name used for naming and tagging"
  type        = string
  default     = "cost-detective"
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "audit-lab"
}

variable "vpc_id" {
  description = "VPC ID where the ASG, ALB, and security groups are deployed"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs the ASG and ALB will use"
  type        = list(string)
}

variable "on_demand_base_capacity" {
  description = "Absolute number of On-Demand instances kept at all times (baseline availability)"
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
  default     = 1
}

variable "max_size" {
  description = "Maximum ASG size"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired ASG size at apply time"
  type        = number
  default     = 1
}

variable "instance_overrides" {
  description = "Mixed Instances Policy overrides. ASG picks the cheapest pool with capacity from this set."
  type = list(object({
    instance_type = string
    weight        = number
  }))
  default = [
    { instance_type = "t3.micro", weight = 1 },
    { instance_type = "t3a.micro", weight = 1 },
    { instance_type = "t3.small", weight = 2 },
    { instance_type = "t3a.small", weight = 2 },
  ]
}

variable "target_cpu_utilization" {
  description = "Target average CPU utilization for the scaling policy"
  type        = number
  default     = 50
}
