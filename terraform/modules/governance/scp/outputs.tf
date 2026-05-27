output "scp_id" {
  description = "ID of the Tagging SCP"
  value       = aws_organizations_policy.require_costcenter_tag.id
}
