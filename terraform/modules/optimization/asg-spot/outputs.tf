output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.spot.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.spot.arn
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.app.id
}

output "alb_dns_name" {
  description = "Public DNS name of the demo ALB — curl this to reach the workload"
  value       = aws_lb.app.dns_name
}

output "alb_security_group_id" {
  description = "Security group ID attached to the ALB"
  value       = aws_security_group.alb.id
}

output "instance_security_group_id" {
  description = "Security group ID attached to ASG instances"
  value       = aws_security_group.instances.id
}

output "scaling_policy_arn" {
  description = "ARN of the CPU target-tracking scaling policy"
  value       = aws_autoscaling_policy.cpu_target_tracking.arn
}
