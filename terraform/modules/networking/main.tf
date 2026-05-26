module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs            = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets = var.public_subnets

  tags = {
    Environment = var.environment
    Purpose     = "lab-waste-simulation"
  }
}
