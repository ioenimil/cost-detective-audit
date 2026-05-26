variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "audit-lab"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "The ID of the Security Group for the ALB"
  type        = string
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
