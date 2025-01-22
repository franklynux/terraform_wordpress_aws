variable "efs_security_group_id" {
    type        = list(string)
    description = "List of security group IDs to associate with the instance"
}

variable "private_subnet_3_id" {
    type        = string
    description = "Private subnet 3 ID for the instance"
  
}

variable "private_subnet_4_id" {
    type        = string
    description = "Private subnet 4 ID for the instance"
  
}