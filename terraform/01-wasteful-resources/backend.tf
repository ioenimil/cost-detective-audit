terraform {
  backend "s3" {
    bucket       = "cost-detective-audit-tf-state-12345"
    key          = "cost-detective-audit/terraform.tfstate"
    region       = "eu-west-1"
    profile      = "nsp-sandbox"
    encrypt      = true
    use_lockfile = true # Uses Terraform 1.7.0+ S3 native state locking capability
  }
}
