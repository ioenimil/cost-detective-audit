output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.wasteful_infrastructure.vpc_id
}

output "idle_instance_id" {
  description = "The ID of the idle EC2 instance"
  value       = module.wasteful_infrastructure.idle_instance_id
}

output "unattached_ebs_volume_ids" {
  description = "The IDs of the unattached EBS volumes"
  value       = module.wasteful_infrastructure.unattached_ebs_volume_ids
}

output "unassociated_eip_id" {
  description = "The ID of the unassociated EIP"
  value       = module.wasteful_infrastructure.unassociated_eip_id
}

output "idle_alb_arn" {
  description = "The ARN of the idle ALB"
  value       = module.wasteful_infrastructure.idle_alb_arn
}
