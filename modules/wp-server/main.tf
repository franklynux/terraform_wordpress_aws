data "aws_ami" "ubuntu" {
    most_recent = true
    owners      = ["099720109477"] # Canonical

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

/*
resource "aws_instance" "wordpress" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    vpc_security_group_ids = var.vpc_security_group_ids
    key_name = var.key_name
    user_data = filebase64("${path.module}/bin/wordpress.sh")
    subnet_id = var.private_subnet_1_id
    associate_public_ip_address = false
    availability_zone = var.AZ

    # Pass RDS endpoint to the user data script
    user_data = templatefile("${path.module}/bin/wordpress.sh", {
      RDS_ENDPOINT = var.rds_endpoint
    })

    tags = {
      name = "DigitalBoost-WordPress"  # Updated to reflect the firm's name
    }
}
*/
