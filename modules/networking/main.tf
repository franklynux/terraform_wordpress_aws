# Create Security Group for Application Load Balancer
resource "aws_security_group" "wp-lb-sg" {
    name        = "ALB-SG"  # Name of the security group for the ALB
    vpc_id      = var.vpc_id  # Associate the security group with the specified VPC
    description = "Security Group for ALB"  # Description of the security group

    tags = {
      Name = "Wordpress-ALB"  # Tag for identifying the ALB security group
    }
}

# Create security group rule for Application Load Balancer
# Allow HTTP traffic into Application Load Balancer
resource "aws_security_group_rule" "ALB_HTTP" {
    type = "ingress"  # Ingress rule for incoming traffic
    from_port = 80  # Allow traffic on port 80 (HTTP)
    to_port = 80
    protocol = "tcp"  # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from any IP address
    security_group_id = aws_security_group.wp-lb-sg.id  # Associate with the ALB security group
}

# Allow HTTPS traffic into Application Load Balancer
resource "aws_security_group_rule" "ALB_HTTPS" {
    type = "ingress"  # Ingress rule for incoming traffic
    from_port = 443  # Allow traffic on port 443 (HTTPS)
    to_port = 443
    protocol = "tcp"  # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from any IP address
    security_group_id = aws_security_group.wp-lb-sg.id  # Associate with the ALB security group
}

# Allow all egress traffic out of ALB
resource "aws_security_group_rule" "allow_all_ALB_egress" {
  type              = "egress"  # Egress rule for outgoing traffic
  from_port         = 0  # Allow all ports
  to_port           = 0
  protocol          = "-1"  # All protocols
  cidr_blocks       = ["0.0.0.0/0"]  # Allow traffic to any IP address
  security_group_id = aws_security_group.wp-lb-sg.id  # Associate with the ALB security group
}

# Create Security Group for SSH Access
resource "aws_security_group" "ssh-sg" {
    name        = "ssh-SG"  # Name of the security group for SSH access
    vpc_id = var.vpc_id  # Associate the security group with the specified VPC
    description = "Security Group for SSH"  # Description of the security group

    tags = {
      Name = "Wordpress-SSH"  # Tag for identifying the SSH security group
    }
}

# Allow SSH traffic on port 22
resource "aws_security_group_rule" "ssh-wp" {
    type = "ingress"  # Ingress rule for incoming traffic
    from_port = 22  # Allow traffic on port 22 (SSH)
    to_port = 22
    protocol = "tcp"  # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from any IP address
    security_group_id = aws_security_group.ssh-sg.id  # Associate with the SSH security group
}

# Allow all egress traffic out of bastion server
resource "aws_security_group_rule" "allow_all_bastion_egress" {
  type              = "egress"  # Egress rule for outgoing traffic
  from_port         = 0  # Allow all ports
  to_port           = 0
  protocol          = "-1"  # All protocols
  cidr_blocks       = ["0.0.0.0/0"]  # Allow traffic to any IP address
  security_group_id = aws_security_group.ssh-sg.id  # Associate with the SSH security group
}

# Create Security Group for WordPress Server
resource "aws_security_group" "wp-vpc-sg" {
    name        = "wordpress-SG"  # Name of the security group for the WordPress server
    vpc_id = var.vpc_id  # Associate the security group with the specified VPC
    description = "Security Group for WordPress EC2 instance"  # Description of the security group

    tags = {
      Name = "Wordpress-main-SG"  # Tag for identifying the WordPress server security group
    }
}

# Allow traffic on port 22 from SSH Security Group into WordPress Server
resource "aws_security_group_rule" "ssh-to-wordpress" {
    type = "ingress"  # Ingress rule for incoming traffic
    from_port = 22  # Allow traffic on port 22 (SSH)
    to_port = 22
    protocol = "tcp"  # TCP protocol
    security_group_id = aws_security_group.wp-vpc-sg.id  # Associate with the WordPress server security group
    source_security_group_id = aws_security_group.ssh-sg.id  # Allow traffic from the SSH security group
}

# Allow traffic from ALB into WordPress Server 
# HTTP traffic access
resource "aws_security_group_rule" "allow_http_from_alb-sg" {
    type = "ingress"  # Ingress rule for incoming traffic
    from_port = 80  # Allow traffic on port 80 (HTTP)
    to_port = 80
    protocol = "tcp"  # TCP protocol
    security_group_id = aws_security_group.wp-vpc-sg.id  # Associate with the WordPress server security group
    source_security_group_id = aws_security_group.wp-lb-sg.id  # Allow traffic from the ALB security group
}

# Allow all egress traffic out of WordPress server
resource "aws_security_group_rule" "allow_all_wordpress_egress" {
  type              = "egress"  # Egress rule for outgoing traffic
  from_port         = 0  # Allow all ports
  to_port           = 0
  protocol          = "-1"  # All protocols
  cidr_blocks       = ["0.0.0.0/0"]  # Allow traffic to any IP address
  security_group_id = aws_security_group.wp-vpc-sg.id  # Associate with the WordPress server security group
}

# Create Security group for RDS MySQL server
resource "aws_security_group" "wp-rds-sg" {
    name        = "RDS-SG"  # Name of the security group for RDS
    vpc_id = var.vpc_id  # Associate the security group with the specified VPC
    description = "Security Group for RDS MySQL & EFS"  # Description of the security group

    tags = {
      Name = "wordpress-RDS"  # Tag for identifying the RDS security group
    }
}

# Configure security group rules for Relational Database (RDS MySQL)
# Allow inbound traffic from WordPress server to RDS MySQL server
resource "aws_security_group_rule" "wp-to-rds" {
    type = "ingress"  # Ingress rule for incoming traffic
    from_port = 3306  # Allow traffic on port 3306 (MySQL)
    to_port = 3306
    protocol = "tcp"  # TCP protocol
    security_group_id = aws_security_group.wp-rds-sg.id  # Associate with the RDS security group
    source_security_group_id = aws_security_group.wp-vpc-sg.id  # Allow traffic from the WordPress server security group
}

# Create Security group for Elastic File System (EFS)
resource "aws_security_group" "wp-efs-sg" {
    name        = "EFS-SG"  # Name of the security group for EFS
    vpc_id = var.vpc_id  # Associate the security group with the specified VPC
    description = "Security Group for EFS"  # Description of the security group

    tags = {
      Name = "wordpress-EFS"  # Tag for identifying the EFS security group
    }
}

# Allow access from WordPress server to EFS
resource "aws_security_group_rule" "wp-to-efs" {
    type = "ingress"  # Ingress rule for incoming traffic
    from_port = 2049  # Allow traffic on port 2049 (NFS for EFS)
    to_port = 2049
    protocol = "tcp"  # TCP protocol
    security_group_id = aws_security_group.wp-efs-sg.id  # Associate with the EFS security group
    source_security_group_id = aws_security_group.wp-vpc-sg.id  # Allow traffic from the WordPress server security group
}

# Allow access on port 22 from SSH security group to EFS
resource "aws_security_group_rule" "ssh-to-efs" {
    type = "ingress"  # Ingress rule for incoming traffic
    from_port = 22  # Allow traffic on port 22 (SSH)
    to_port = 22
    protocol = "tcp"  # TCP protocol
    security_group_id = aws_security_group.wp-efs-sg.id  # Associate with the EFS security group
    source_security_group_id = aws_security_group.ssh-sg.id  # Allow traffic from the SSH security group
}
