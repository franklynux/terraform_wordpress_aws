output "kms_key_id" {
    value = aws_kms_key.wp_efs_kms.key_id
    description = "KMS key ID for EFS"
}