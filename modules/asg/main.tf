# Retrieve the most recent Ubuntu AMI
data "aws_ami" "ubuntu" {
    most_recent = true  # Get the most recent AMI
    owners      = ["099720109477"] # Canonical

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]  # Filter for Ubuntu Jammy AMIs
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]  # Filter for HVM virtualization type
    }

    filter {
        name   = "root-device-type"
        values = ["ebs"]  # Filter for EBS root device type
    }
}

# Create WordPress Launch Template
resource "aws_launch_template" "wp-lanch_template" {
  name  = "DigitalBoost-WordPress-Server"  # define the name of the launch template
  image_id      = data.aws_ami.ubuntu.id  # Use the retrieved Ubuntu AMI
  instance_type = var.instance_type  # Instance type for the WordPress server
  key_name      = var.key_name  # Key pair for SSH access
  vpc_security_group_ids =  var.vpc_security_group_ids  # Security groups for the instance
  user_data = filebase64("${path.module}/bin/wordpress.sh")  # User data script for initialization
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name  # IAM instance profile for the EC2 instance
  }

  monitoring {
    enabled = true  # Enable detailed monitoring
  }

  tag_specifications {
    resource_type = "instance"  # Specify that tags are for EC2 instances
    tags = {
      Name = "DigitalBoost-WordPress-Server"  # Updated to reflect the firm's name
      CreatedBy = "Terraform"  # Indicate that this resource was created using Terraform
    }
  }

  block_device_mappings {
    device_name = "/dev/sda1"  # Device name for the root volume
    ebs {
      volume_size = 30  # Size of the root volume in GB
      volume_type = "gp2"  # General Purpose SSD
    }
  }

  placement {
    availability_zone = "us-east-1a"  # Availability zone for the instance
  }
}

# Create IAM role for EC2 instances
resource "aws_iam_role" "wordpress_ec2_role" {
  name = "wordpress_role_for_ssm_access"  # Name of the IAM role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"  # Allow EC2 to assume this role
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"  # Principal service
        }
      }
    ]
  })
}

# Attach SSM read-only access policy to the role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.wordpress_ec2_role.name  # Attach policy to the IAM role
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"  # SSM read-only access policy
}

# Create an instance profile for the role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "wordpress_profile_ssm_access_${random_string.suffix.result}"  # Name of the instance profile generated with a random suffix
  role = aws_iam_role.wordpress_ec2_role.name  # Associate the IAM role with the instance profile
}

# Generate a random suffix for the instance profile
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Configure Auto-scaling Group for launch template
resource "aws_autoscaling_group" "wp-asg" {
  desired_capacity   = 2  # Desired number of instances
  max_size           = 3  # Maximum number of instances
  min_size           = 1  # Minimum number of instances
  health_check_grace_period = 500  # Grace period for health checks
  health_check_type         = "ELB"  # Health check type
  target_group_arns = [var.target_group_arn]  # Target group for the ASG
  vpc_zone_identifier = [ var.private_subnet_1_id, var.private_subnet_2_id ]  # Subnets for the ASG
  
  launch_template {
    id      = aws_launch_template.wp-lanch_template.id  # Use the defined launch template
    version = "$Latest"  # Use the latest version of the launch template
  }

  tag {
    key                 = "Name"  # Tag key
    value               = "DigitalBoost-WordPress-Server"  # Updated to reflect the firm's name
    propagate_at_launch = true  # Propagate the tag to instances
  }

  tag {
    key                 = "CreatedBy"  # Tag key
    value               = "Terraform"  # Indicate that this resource was created using Terraform
    propagate_at_launch = true  # Propagate the tag to instances
  }
}

# Auto-scaling policy to scale based on target tracking
resource "aws_autoscaling_policy" "target_tracking" {
  name                   = "target-tracking"
  autoscaling_group_name = aws_autoscaling_group.wp-asg.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    target_value       = 50.0  # Target CPU utilization
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"  # Use predefined metric for CPU utilization
    }

  }
}

/*
# Configure CloudWatch metric alarm and alarm action for high CPU Utilization
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-alarm"  # Name of the alarm
  comparison_operator = "GreaterThanThreshold"  # Condition for the alarm
  evaluation_periods  = 2  # Number of periods to evaluate
  metric_name         = "CPUUtilization"  # Metric to monitor
  namespace           = "AWS/EC2"  # Namespace for the metric
  period              = 60  # Period for the metric
  statistic           = "Average"  # Statistic to evaluate
  threshold           = 50  # Threshold for the alarm
  alarm_description  = "Scale up when CPU > 50% for 2 mins"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wp-asg.name  # Dimension for the alarm
  }

  alarm_actions = [
    aws_autoscaling_policy.target_tracking.arn  # Action to take when the alarm is triggered
  ]
}

# Configure CloudWatch metric alarm and alarm action for low CPU Utilization
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "low-cpu-alarm"  # Name of the alarm
  comparison_operator = "LessThanThreshold"  # Condition for the alarm
  evaluation_periods  = 2  # Number of periods to evaluate
  metric_name         = "CPUUtilization"  # Metric to monitor
  namespace           = "AWS/EC2"  # Namespace for the metric
  period              = 60  # Period for the metric
  statistic           = "Average"  # Statistic to evaluate
  threshold           = 20  # Threshold for the alarm
  alarm_description  = "Scale down when CPU < 20% for 2 mins"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wp-asg.name  # Dimension for the alarm
  }

  alarm_actions = [
    aws_autoscaling_policy.target_tracking.arn  # Action to take when the alarm is triggered
  ]
}
*/

# Bastion Host Launch Template
resource "aws_launch_template" "bastion-lanch_template" {
  name = "DigitalBoost-Bastion-Server"  # Bastion host launch template name
  image_id      = data.aws_ami.ubuntu.id  # Use the retrieved Ubuntu AMI
  instance_type = "t2.micro"  # Instance type for the bastion host
  key_name      = var.key_name  # Key pair for SSH access
  instance_initiated_shutdown_behavior = "terminate"  # Terminate instance on shutdown
  vpc_security_group_ids =  [var.ssh_security_group_id]  # Security group for the bastion host
  user_data = filebase64("${path.module}/bin/bastion.sh")  # User data script for initialization
  monitoring {
    enabled = true  # Enable detailed monitoring
  }
  tag_specifications {
    resource_type = "instance"  # Specify that tags are for EC2 instances
    tags = {
      Name = "DigitalBoost-Bastion-Server"  # Updated to reflect the firm's name
      CreatedBy = "Terraform"  # Indicate that this resource was created using Terraform
    }
  }
  block_device_mappings {
    device_name = "/dev/sda1"  # Device name for the root volume
    ebs {
      volume_size = 20  # Size of the root volume in GB
      volume_type = "gp2"  # General Purpose SSD
    }
  }
  placement {
    availability_zone = "us-east-1a"  # Availability zone for the instance
  }
}

# Configure Auto-scaling Group for bastion host launch template
resource "aws_autoscaling_group" "bastion-asg" {
  desired_capacity   = 1  # Desired number of instances
  max_size           = 2  # Maximum number of instances
  min_size           = 1  # Minimum number of instances
  health_check_grace_period = 300  # Grace period for health checks
  health_check_type         = "ELB"  # Health check type
  vpc_zone_identifier = var.public_subnet_ids  # Subnets for the ASG
  
  launch_template {
    id      = aws_launch_template.bastion-lanch_template.id  # Use the defined launch template
    version = "$Latest"  # Use the latest version of the launch template
  }

  tag {
    key                 = "Name"  # Tag key
    value               = "DigitalBoost-Bastion-Server"  # Updated to reflect the firm's name
    propagate_at_launch = true  # Propagate the tag to instances
  }

  tag {
    key                 = "CreatedBy"  # Tag key
    value               = "Terraform"  # Indicate that this resource was created using Terraform
    propagate_at_launch = true  # Propagate the tag to instances
  }
}
