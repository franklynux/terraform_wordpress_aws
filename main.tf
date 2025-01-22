terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # Specifies the AWS provider
      version = "~> 5.0"          # Specifies the version of the AWS provider
    }
  }
}

provider "aws" {
  region = var.region # Sets the AWS region for the resources
}

# VPC module
module "vpc" {
  source = "./modules/vpc"  # Source path for the VPC module
}

# Networking module
module "networking" {
  source = "./modules/networking"  # Source path for the Networking module
  vpc_id = module.vpc.vpc_id        # Passes the VPC ID to the Networking module
}

# Elastic File System module
module "efs" {
  source                = "./modules/efs"  # Source path for the EFS module
  private_subnet_3_id   = module.vpc.private_subnet_3_id  # Passes private subnet ID
  private_subnet_4_id   = module.vpc.private_subnet_4_id  # Passes private subnet ID
  efs_security_group_id = [module.networking.efs_security_group_id]  # Passes EFS security group ID
}

# Application Load Balancer module
module "alb" {
  source                = "./modules/alb"  # Source path for the ALB module
  alb_security_group_id = module.networking.alb_security_group_id  # Passes ALB security group ID
  vpc_id                = module.vpc.vpc_id        # Passes the VPC ID
  public_subnet_ids     = module.vpc.public_subnet_ids  # Passes public subnet IDs
}

# RDS MySQL module
module "rds" {
  source = "./modules/rds"  # Source path for the RDS module
  private_subnet_3_id    = module.vpc.private_subnet_3_id  # Passes private subnet ID
  private_subnet_4_id    = module.vpc.private_subnet_4_id  # Passes private subnet ID
  vpc_id                 = module.vpc.vpc_id        # Passes the VPC ID
  vpc_security_group_ids = [module.networking.rds_security_group_id]  # Passes RDS security group ID
}

# ASG module
module "asg" {
  source                 = "./modules/asg"  # Source path for the ASG module
  name_prefix            = "wordpress-asg"   # Prefix for the ASG name
  vpc_security_group_ids = [module.networking.vpc_security_group_id]  # Passes VPC security group ID
  target_group_arn       = module.alb.target_group_arn  # Passes target group ARN from ALB
  private_subnet_1_id    = module.vpc.private_subnet_1_id  # Passes private subnet ID
  private_subnet_2_id    = module.vpc.private_subnet_2_id  # Passes private subnet ID
  ssh_security_group_id  = module.networking.ssh_security_group_id  # Passes SSH security group ID
  public_subnet_ids      = module.vpc.public_subnet_ids  # Passes public subnet IDs
  rds_endpoint           = module.rds.rds_endpoint  # Passes RDS endpoint
}

# S3 bucket for backend statefile
module "s3" {
  source = "./modules/s3"  # Source path for the S3 module
}

# DynamoDB table for locking statefile
module "dynamodb" {
  source = "./modules/dynamodb"  # Source path for the DynamoDB module
}

/*
# WordPress Server module - Depends on VPC, Networking, EFS, and RDS (for database connection)
module "wp-server" {
  source                 = "./modules/wp-server"  # Source path for the WordPress Server module
  vpc_security_group_ids = [module.networking.vpc_security_group_id]  # Passes VPC security group ID
  private_subnet_1_id    = module.vpc.private_subnet_1_id  # Passes private subnet ID
}
*/
