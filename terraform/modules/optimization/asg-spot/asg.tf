# ---------------------------------------------------------------------------
# Launch template
# ---------------------------------------------------------------------------
resource "aws_launch_template" "app" {
  name_prefix = "${local.name_prefix}-lt-"
  image_id    = data.aws_ssm_parameter.al2023_ami.value
  # instance_type is intentionally omitted: the Mixed Instances Policy below
  # supplies it via overrides so the ASG can shop across pools.

  iam_instance_profile {
    arn = aws_iam_instance_profile.instance.arn
  }

  vpc_security_group_ids = [aws_security_group.instances.id]

  metadata_options {
    http_tokens                 = "required" # IMDSv2 only
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = false # CloudWatch detailed monitoring is a paid feature; keep off for the lab
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -euo pipefail
              dnf -y update
              dnf -y install httpd stress-ng
              TOKEN=$(curl -sS -X PUT "http://169.254.169.254/latest/api/token" \
                -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
              IID=$(curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" \
                http://169.254.169.254/latest/meta-data/instance-id)
              LIFE=$(curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" \
                http://169.254.169.254/latest/meta-data/instance-life-cycle || echo unknown)
              cat > /var/www/html/index.html <<HTML
              <h1>cost-detective spot demo</h1>
              <p>instance: $IID</p>
              <p>lifecycle: $LIFE</p>
              HTML
              systemctl enable --now httpd
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = local.common_tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.common_tags
  }

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------
# Auto Scaling Group with Mixed Instances Policy
# ---------------------------------------------------------------------------
resource "aws_autoscaling_group" "spot" {
  name                = "${local.name_prefix}-asg"
  vpc_zone_identifier = var.subnet_ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 120
  capacity_rebalance        = true 

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
      spot_allocation_strategy                 = "price-capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.app.id
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = var.instance_overrides
        content {
          instance_type     = override.value.instance_type
          weighted_capacity = tostring(override.value.weight)
        }
      }
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

# ---------------------------------------------------------------------------
# Target-tracking scaling policy
# ---------------------------------------------------------------------------
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${local.name_prefix}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.spot.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.target_cpu_utilization
  }
}
