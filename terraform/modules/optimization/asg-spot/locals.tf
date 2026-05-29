locals {
  name_prefix = "${var.project_name}-spot"

  common_tags = {
    Name        = local.name_prefix
    Project     = var.project_name
    Environment = var.environment
    CostCenter  = "true" # required by the governance SCP from stack 02
    Workload    = "stateless-web"
    Pattern     = "asg-mixed-instances-spot"
  }
}
