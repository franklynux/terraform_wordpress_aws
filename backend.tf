# This file is used to configure the backend for the Terraform state file.
# The backend is used to store the state file in a remote location.
# This is useful when working in a team environment where multiple people are working on the same infrastructure.
# The backend configuration is stored in a separate file so that it can be easily shared with other team members.

terraform {
  backend "s3" {
    bucket = "wordpress-terraform-statefile"  # The name of the S3 bucket to store the state file
    key    = "terraform.tfstate"              # The key (path) within the bucket where the state file will be stored
    region = "us-east-1"                       # The AWS region where the S3 bucket is located
    encrypt = true                             # Enable server-side encryption for the state file
    profile = "default"                        # The AWS CLI profile to use for authentication
    dynamodb_table = "wordpress-dynamodb"     # The DynamoDB table used for state locking to prevent concurrent operations
  }
}
