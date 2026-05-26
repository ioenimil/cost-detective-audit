resource "aws_security_group" "alb_sg" {
  name        = "idle-alb-sg"
  description = "Security group for idle ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "idle-alb-sg"
    Environment = var.environment
  }
}
