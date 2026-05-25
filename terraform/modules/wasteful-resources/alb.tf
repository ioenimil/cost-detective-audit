resource "aws_security_group" "alb_sg" {
  name        = "idle-alb-sg"
  description = "Security group for idle ALB"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "idle-alb-sg"
    Environment = var.environment
  }
}

resource "aws_lb" "idle_alb" {
  name               = "idle-alb-simulation"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

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
  vpc_id   = module.vpc.vpc_id

  tags = {
    Name        = "idle-tg"
    Purpose     = "lab-waste-simulation"
    Environment = var.environment
  }
}
