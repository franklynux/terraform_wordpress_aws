output "ami_id" {
    value       = data.aws_ami.ubuntu.id
    description = "AMI ID"
}

/*
output "instance_public_dns" {
    value       = aws_instance.wordpress.public_dns
    description = "Public DNS"
}
*/
  
