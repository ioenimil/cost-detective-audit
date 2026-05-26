resource "aws_ebs_volume" "zombie" {
  count             = var.ebs_volume_count
  availability_zone = var.azs[count.index % length(var.azs)]
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type

  tags = {
    Name        = "zombie-ebs-${count.index + 1}"
    Purpose     = "lab-waste-simulation"
    Environment = var.environment
  }
}
