variable "instance_type" {
    type = string
    default = "t2.small"
    description = "Instance for WordPress"
  
}

variable "key_name" {
    type = string
    default = "wp-key"
    description = "Key pair for WordPress"
  
}

variable "AZ" {
    type = string
    default = "us-east-1a"
    description = "Availability Zone for WordPress"
  
}

variable "vpc_security_group_ids" {
    type = list(string)
    description = "Security group for WordPress"
  
}

/*
variable "private_subnet_1_id" {
    type = string
    description = "Private subnet 1 for WordPress"
  
}
*/