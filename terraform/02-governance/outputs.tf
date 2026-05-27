output "budget_arn" {
  description = "ARN of the AWS Budget"
  value       = module.budget.budget_arn
}

output "scp_id" {
  description = "ID of the Tagging SCP"
  value       = module.scp.scp_id
}
