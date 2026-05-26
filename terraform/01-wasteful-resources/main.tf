module "networking" {
  source = "../modules/networking"

  environment    = var.environment
  vpc_name       = var.vpc_name
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets
  azs            = var.azs
}

module "security" {
  source = "../modules/security"

  environment = var.environment
  vpc_id      = module.networking.vpc_id
}

module "wasteful_infrastructure" {
  source = "../modules/wasteful-resources"

  environment      = var.environment
  vpc_id           = module.networking.vpc_id
  public_subnets   = module.networking.public_subnets
  azs              = var.azs
  alb_sg_id        = module.security.alb_sg_id
  instance_type    = var.instance_type
  ebs_volume_count = var.ebs_volume_count
  ebs_volume_size  = var.ebs_volume_size
  ebs_volume_type  = var.ebs_volume_type
}
