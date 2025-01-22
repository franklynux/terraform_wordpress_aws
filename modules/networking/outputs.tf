output "vpc_security_group_id" {
    value = aws_security_group.wp-vpc-sg.id
    description = "VPC Security Group ID"
}

output "alb_security_group_id" {
    value = aws_security_group.wp-lb-sg.id
    description = "ALB Security Group ID"
  
}

output "ssh_security_group_id" {
    value = aws_security_group.ssh-sg.id
    description = "SSH Security Group ID"
}

output "rds_security_group_id" {
    value = aws_security_group.wp-rds-sg.id
    description = "RDS Security Group ID"
}

output "efs_security_group_id" {
    value = aws_security_group.wp-efs-sg.id
    description = "EFS Security Group ID"
}
  