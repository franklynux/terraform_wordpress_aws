output "autoscaling_group_name" {
    value = aws_autoscaling_group.wp-asg.name
    description = "The name of the autoscaling group"
    sensitive = false
}

output "ami_id" {
    value       = data.aws_ami.ubuntu.id
    description = "AMI ID"
}