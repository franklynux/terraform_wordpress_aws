output "rds_endpoint" {
    value       = aws_db_instance.wordpress_rds.endpoint
    description = "RDS Endpoint URL"
}
