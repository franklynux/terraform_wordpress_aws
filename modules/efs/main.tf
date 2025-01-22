# Create a KMS key for EFS encryption
resource "aws_kms_key" "wp_efs_kms" {
  description = "KMS key for EFS encryption"  # Description of the KMS key
  deletion_window_in_days = 10  # Days before the key can be deleted

  tags = {
    Name = "efs-kms-key"  # Tag for identifying the KMS key
  }
}

# Create an alias for the KMS key
resource "aws_kms_alias" "wp_kms_alias" {
    name          = "alias/wp-efs-kms"  # Alias name for the KMS key
    target_key_id = aws_kms_key.wp_efs_kms.key_id  # Associate the alias with the KMS key
}

# Create the EFS file system
resource "aws_efs_file_system" "wp-efs" {
  creation_token = "efs-for-wordpress"  # Unique token for creating the EFS
  encrypted      = true  # Enable encryption for the EFS
  kms_key_id = aws_kms_key.wp_efs_kms.arn  # Use the KMS key for encryption
  performance_mode = "generalPurpose"  # Performance mode for the EFS
  throughput_mode  = "bursting"  # Throughput mode for the EFS

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"  # Transition to Infrequent Access after 30 days
  }

  tags = {
    Name = "EFS-for-wordpress"  # Tag for identifying the EFS file system
  }
}

# Create EFS Mount targets in specified subnets
resource "aws_efs_mount_target" "mnt-subnet-1" {
    file_system_id = aws_efs_file_system.wp-efs.id  # Associate with the EFS file system
    subnet_id = var.private_subnet_3_id  # Specify the subnet for the mount target
    security_groups = var.efs_security_group_id  # Security group for the mount target
}

resource "aws_efs_mount_target" "mnt-subnet-2" {
    file_system_id = aws_efs_file_system.wp-efs.id  # Associate with the EFS file system
    subnet_id = var.private_subnet_4_id  # Specify the subnet for the mount target
    security_groups = var.efs_security_group_id  # Security group for the mount target
}

# Create an access point on EFS for the WordPress application
resource "aws_efs_access_point" "wordpress" {
  file_system_id = aws_efs_file_system.wp-efs.id  # Associate with the EFS file system
  posix_user {
    gid = 0  # Group ID for the access point
    uid = 0  # User ID for the access point
  }

  root_directory {
    path = "/wordpress"  # Root directory for the access point

    creation_info {
      owner_gid   = 0  # Owner group ID for the root directory
      owner_uid   = 0  # Owner user ID for the root directory
      permissions = 0755  # Permissions for the root directory
    }
  }
}
