resource "aws_dynamodb_table" "wordpress-terraform-lock" {
  name           = "wordpress-dynamodb"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  deletion_protection_enabled = false
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "DigitalBoost-dynamodb-lock-table" # dynamodb lock table
  }
  
}