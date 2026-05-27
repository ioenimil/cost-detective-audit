module "networking" {
  source = "../modules/networking"

  environment    = var.environment
  vpc_name       = var.vpc_name
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets
  azs            = var.azs
}

module "asg_spot" {
  source = "../modules/optimization/asg-spot"

  project_name = var.project_name
  environment  = var.environment

  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.public_subnets

  on_demand_base_capacity                  = var.on_demand_base_capacity
  on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
  min_size                                 = var.min_size
  max_size                                 = var.max_size
  desired_capacity                         = var.desired_capacity
  target_cpu_utilization                   = var.target_cpu_utilization
}
