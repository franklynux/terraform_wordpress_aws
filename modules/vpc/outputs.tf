output "vpc_id" {
    value = aws_vpc.main.id
    description = "VPC ID"
    }

# Output all private subnet IDs
output "private_subnet_ids" {
  value = aws_subnet.private-subnets[*].id
}

# Output all private subnet IDs
output "public_subnet_ids" {
  value = aws_subnet.public-subnets[*].id
}

# Output only Private Subnet 1 (index 0)
output "private_subnet_1_id" {
  value = aws_subnet.private-subnets[0].id
}

# Output only Private Subnet 2 (index 1)
output "private_subnet_2_id" {
  value = aws_subnet.private-subnets[1].id
}

# Output only Private Subnet 3 (index 2)
output "private_subnet_3_id" {

  value = aws_subnet.private-subnets[2].id
  description = "Private Subnet 3 ID"

}

# Output only Private Subnet 4 (index 3)
output "private_subnet_4_id" {
  value = aws_subnet.private-subnets[3].id
}

output "availability_zones" {
  value = data.aws_availability_zones.AZs.names
}
