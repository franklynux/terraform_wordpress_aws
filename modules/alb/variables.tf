variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket"
  type        = string
  default = "wordpress-lb-logs"
}

