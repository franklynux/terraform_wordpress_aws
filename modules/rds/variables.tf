
variable "allocated_storage" {
  type        = number
  default     = 20
  description = "The size of the allocated storage in GB"
}


variable "storage_type" {
    type = string
    default = "gp2"
    description = "Strong type for RDS"
    
  }

variable "engine" {
    type = string
    default = "mysql"
    description = "Engine for RDS"
    
  }

variable "engine_version" {
    type = string
    default = "8.0"
    description = "Version for RDS"
    
  }

variable "instance_class" {
    type = string
    default = "db.t3.small"
    description = "Instance Class for RDS"
    
  }

variable "db_name" {
    type = string
    default = "wordpressDB"
    description = "Database name for RDS"
    
  }

variable "username" {
    type = string
    default = "wordpress"
    description = "Username for RDS"
}

variable "password" {
    type = string
    default = "word1press2!"
    description = "Password for RDS"
}

variable "parameter_group_name" {
    type = string
    default = "default.mysql8.0"
    description = "Parameter group name for RDS"
}

variable "multi_az" {
    type = bool
    default = true
    description = "Multi AZ for RDS"
}

variable "private_subnet_3_id" {
    type = string
    description = "Private subnet 3 id"
}

variable "private_subnet_4_id" {
    type = string
    description = "Private subnet 4 id"
}

variable "vpc_id" {
  type = string
  description = "VPC id"
}

variable "vpc_security_group_ids" {
  type = list(string)
  description = "VPC security group ids"
}

# variable "rds_endpoint" {
#   type = string
#   description = "RDS endpoint"
# }
