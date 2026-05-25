resource "aws_eip" "orphan" {
  domain = "vpc"

  tags = {
    Name        = "orphan-eip"
    Purpose     = "lab-waste-simulation"
    Environment = var.environment
  }
}
