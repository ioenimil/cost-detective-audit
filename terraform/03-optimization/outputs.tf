output "vpc_id" {
  description = "VPC ID for the optimization demo"
  value       = module.networking.vpc_id
}

output "asg_name" {
  description = "Name of the Mixed-Instances ASG"
  value       = module.asg_spot.asg_name
}

output "alb_dns_name" {
  description = "Public DNS of the demo ALB — curl this to hit the workload"
  value       = module.asg_spot.alb_dns_name
}

output "launch_template_id" {
  description = "Launch Template ID used by the ASG"
  value       = module.asg_spot.launch_template_id
}

output "scaling_policy_arn" {
  description = "ARN of the target-tracking scaling policy"
  value       = module.asg_spot.scaling_policy_arn
}
