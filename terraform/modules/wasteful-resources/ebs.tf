resource "aws_ebs_volume" "zombie" {
  count             = 2
  availability_zone = slice(data.aws_availability_zones.available.names, 0, 2)[count.index]
  size              = 50
  type              = "gp3"

  tags = {
    Name        = "zombie-ebs-${count.index + 1}"
    Purpose     = "lab-waste-simulation"
    Environment = var.environment
  }
}
