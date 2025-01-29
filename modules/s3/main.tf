# Create an S3 bucket for storing the Terraform state file
resource "aws_s3_bucket" "s3-statefile" {
  bucket = var.bucket_name  # Name of the S3 bucket
  force_destroy = true  # Allow the bucket to be destroyed even if it contains objects
  
  tags = {
    Name = "DigitalBoost-Remote-Statefile-Storage"  # Tag for identifying the S3 bucket
  }
}


