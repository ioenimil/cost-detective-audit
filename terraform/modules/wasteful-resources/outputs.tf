output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.vpc_id
}

output "idle_instance_id" {
  description = "The ID of the idle EC2 instance"
  value       = aws_instance.idle.id
}

output "unattached_ebs_volume_ids" {
  description = "The IDs of the unattached EBS volumes"
  value       = aws_ebs_volume.zombie[*].id
}

output "unassociated_eip_id" {
  description = "The ID of the unassociated EIP"
  value       = aws_eip.orphan.id
}

output "idle_alb_arn" {
  description = "The ARN of the idle ALB"
  value       = aws_lb.idle_alb.arn
}
