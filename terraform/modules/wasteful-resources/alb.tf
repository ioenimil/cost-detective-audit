resource "aws_lb" "idle_alb" {
  name               = "idle-alb-simulation"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  tags = {
    Name        = "idle-alb"
    Purpose     = "lab-waste-simulation"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "idle_tg" {
  name     = "idle-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name        = "idle-tg"
    Purpose     = "lab-waste-simulation"
    Environment = var.environment
  }
}
