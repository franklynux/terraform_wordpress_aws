/*
variable "name_prefix" {
    type = string
    description = "Name prefic of launch template"
    default = "wordpress-template"
  
}
*/

variable "instance_type" {
    type = string
    description = "Instance type"
    default = "t2.small"
}

variable "key_name" {
    type = string
    description = "key pair name"
    default = "wp-key"
  
}


/*
variable "image_id" {
    type = string
    description = "ami id"
  
}
*/


variable "vpc_security_group_ids" {
    type = list(string)
    description = "security group id"
  
}


variable "private_subnet_1_id" {
    type = string
    description = "private subnet 1 id"
  
}

variable "private_subnet_2_id" {
    type = string
    description = "private subnet 2 id"
  
}

variable "public_subnet_ids" {
    type = list(string)
    description = "public subnet id"
  
}

variable "target_group_arn" {
    type = string
    description = "target group arn"
  
}

variable "ssh_security_group_id" {
    type = string
    description = "ssh security group id"
  
}

variable "rds_endpoint" {
    type = string
    description = "RDS endpoint"
}

/*
variable "iam_instance_profile" {
    type = string
    description = "iam instance profile to retrieve RDS endpoint from ssm parameter store"
  
}
*/

