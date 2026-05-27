module "budget" {
  source       = "../modules/governance/budget"
  alert_email  = var.alert_email
  limit_amount = "15.0"
}

module "scp" {
  source = "../modules/governance/scp"
}
