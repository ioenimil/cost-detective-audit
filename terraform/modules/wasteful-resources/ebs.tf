resource "aws_ebs_volume" "zombie" {
  count             = var.ebs_volume_count
  availability_zone = slice(data.aws_availability_zones.available.names, 0, 2)[count.index]
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type

  tags = {
    Name        = "zombie-ebs-${count.index + 1}"
    Purpose     = "lab-waste-simulation"
    Environment = var.environment
  }
}
