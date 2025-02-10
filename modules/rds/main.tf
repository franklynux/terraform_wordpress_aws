# Create an RDS instance for the WordPress database
resource "aws_db_instance" "wordpress_rds" {
  allocated_storage      = var.allocated_storage  # Storage allocated for the database
  storage_type           = var.storage_type  # Type of storage (e.g., gp2)
  engine                 = var.engine  # Database engine (e.g., MySQL)
  engine_version         = var.engine_version  # Version of the database engine
  instance_class         = var.instance_class  # Instance class for the RDS instance
  db_name                = var.db_name  # Name of the database to create
  identifier             = var.identifier  # Identifier for the database
  username               = var.username  # Master username for the database
  password               = var.password  # Master password for the database
  parameter_group_name   = var.parameter_group_name  # Parameter group for the database
  db_subnet_group_name   = aws_db_subnet_group.subnet-grp-rds.name  # Subnet group for the RDS instance
  skip_final_snapshot    = true  # Skip final snapshot on deletion
  publicly_accessible    = false  # Do not make the RDS instance publicly accessible
  vpc_security_group_ids = var.vpc_security_group_ids  # Security groups for the RDS instance
  multi_az               = var.multi_az  # Enable Multi-AZ deployment for high availability

  tags = {
    Name = "DigitalBoost-WordPress-RDS"  
  }
  
}



# Store the RDS endpoint in Parameter Store
resource "aws_ssm_parameter" "rds_endpoint" {
  name  = "/wordpress/rds_endpoint"  # Name of the parameter in SSM
  type  = "String"  # Type of the parameter
  value = aws_db_instance.wordpress_rds.endpoint  # Value of the parameter (RDS endpoint)
}

# Create a DB subnet group for the RDS instance
resource "aws_db_subnet_group" "subnet-grp-rds" {
    name       = "subnet-grp-rds"  # Name of the subnet group
    subnet_ids = [var.private_subnet_3_id, var.private_subnet_4_id]  # Subnets for the RDS instance

    tags = {
      Name = "DigitalBoost-WordPress-RDS-Subnet-Group"  # Updated to reflect the firm's name
    }
}
