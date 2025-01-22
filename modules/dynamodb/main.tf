resource "aws_dynamodb_table" "wordpress-terraform-lock" {
  name           = "wordpress-dynamodb"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  deletion_protection_enabled = true
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "wordpress-dynamodb"
  }
  
}