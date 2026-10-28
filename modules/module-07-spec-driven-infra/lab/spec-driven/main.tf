# data source: no hardcoded AMI id (C-001)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "checkout_web" {
  name_prefix   = "checkout-web-"
  image_id      = data.aws_ami.al2023.id # C-001: AMI resolved via data source, not hardcoded
  instance_type = "t3.micro"

  # SC-005 / FR-005: require IMDSv2 tokens (CKV_AWS_79) -- blocks the SSRF-to-credentials
  # pivot that IMDSv1's unsigned metadata requests allow.
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "checkout_web" {
  name = "checkout-web-asg"

  # C-002: launch template wired directly into the ASG (latest version), not applied
  # independently.
  launch_template {
    id      = aws_launch_template.checkout_web.id
    version = "$Latest"
  }

  # SC-003 / FR-003: peak bounded to 2x the 2-instance steady-state baseline, not a
  # round-number guess.
  min_size = 2
  max_size = 4

  # SC-001 / FR-001: use a reviewed 180-second health-check grace period.
  # This configuration uses EC2 checks; it does not test application startup.
  health_check_grace_period = 180
  health_check_type         = "EC2"

  # SC-002 / FR-002: prefer the oldest launch-template version at scale-in.
  # AWS balances Availability Zones first, so this is not a guarantee.
  termination_policies = ["OldestLaunchTemplate", "OldestInstance", "Default"]

  # SC-004 / FR-004: instance warmup is the knob the target-tracking policy below actually
  # waits on. AWS documents that target-tracking and step-scaling policies can start a
  # scale-out immediately, without waiting for the cooldown to end, so warmup is what makes
  # this tier react to a flash sale.
  default_instance_warmup = 90

  # Set explicitly rather than left at the provider's 5-minute default. It governs simple
  # scaling policies and can still delay scale-in. It does not gate the scale-out above.
  default_cooldown = 90

  availability_zones = ["us-east-1a"]
}

# SC-004 / FR-004: target tracking on average CPU with headroom before saturation.
resource "aws_autoscaling_policy" "checkout_web_cpu" {
  name                   = "checkout-web-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.checkout_web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 55
  }
}
