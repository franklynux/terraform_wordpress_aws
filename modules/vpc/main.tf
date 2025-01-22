# Build VPC to deploy WordPress site
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"  # CIDR block for the VPC
    enable_dns_hostnames = true   # Enable DNS hostnames for instances
    enable_dns_support = true      # Enable DNS support for the VPC

    tags = {
        Name = "WordPress-vpc"     # Tag for identifying the VPC
    }
}

# Get list of Availability Zones in a Region
data "aws_availability_zones" "AZs" {
    state = "available"  # Filter for available availability zones
    filter {
      name   = "opt-in-status"
      values = ["opt-in-not-required"]  # Only include zones that do not require opt-in
    }
}

# Create Private and Public Subnets
# Public Subnet 1
resource "aws_subnet" "public-subnets" {
    count = 2  # Create two public subnets
    vpc_id = aws_vpc.main.id  # Associate the subnets with the main VPC
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)  # Calculate CIDR block for the subnet
    map_public_ip_on_launch = true  # Assign public IPs to instances launched in this subnet
    availability_zone = data.aws_availability_zones.AZs.names[count.index]  # Assign availability zone

    tags = {
        Name = "Public-subnet-${count.index}"  # Tag for identifying the public subnets
        Tier = "public"  # Tag to indicate the tier of the subnet
    }
}

# Private Subnet 1
resource "aws_subnet" "private-subnets" {
    count = 4  # Create four private subnets
    vpc_id = aws_vpc.main.id  # Associate the subnets with the main VPC
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2)  # Calculate CIDR block for the subnet
    map_public_ip_on_launch = false  # Do not assign public IPs to instances in this subnet
    availability_zone = element(data.aws_availability_zones.AZs.names, count.index % 2)  # Assign availability zone

    tags = {
        Name = "private-subnet-${count.index}"  # Tag for identifying the private subnets
        Tier = "private"  # Tag to indicate the tier of the subnet
    }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id  # Associate the internet gateway with the main VPC
}

# NAT Gateway in 2 public subnets
resource "aws_nat_gateway" "NATgw-1" {
    allocation_id = aws_eip.NATgw_eip_1.id  # Associate the NAT gateway with an Elastic IP
    subnet_id = aws_subnet.public-subnets[0].id  # Place the NAT gateway in the first public subnet
}

resource "aws_nat_gateway" "NATgw-2" {
    allocation_id = aws_eip.NATgw_eip_2.id  # Associate the NAT gateway with an Elastic IP
    subnet_id = aws_subnet.public-subnets[1].id  # Place the NAT gateway in the second public subnet
}

# EIP for NATgateway 1
resource "aws_eip" "NATgw_eip_1" {
    domain = "vpc"  # Specify that the Elastic IP is for a VPC
}

# EIP for NATgateway 2
resource "aws_eip" "NATgw_eip_2" {
    domain = "vpc"  # Specify that the Elastic IP is for a VPC
}

# Route Table for Public Subnets
resource "aws_route_table" "public-rt" {
    vpc_id = aws_vpc.main.id  # Associate the route table with the main VPC

    tags = {
      Name = "public-route-table"  # Tag for identifying the public route table
    }
}

# Route Table for Private Subnets
resource "aws_route_table" "private-rt-1" {
    vpc_id = aws_vpc.main.id  # Associate the route table with the main VPC

    tags = {
      Name = "private-route-table"  # Tag for identifying the first private route table
    }
}

resource "aws_route_table" "private-rt-2" {
    vpc_id = aws_vpc.main.id  # Associate the route table with the main VPC

    tags = {
      Name = "private-route-table-2"  # Tag for identifying the second private route table
    }
}

# Route for Public Subnets
resource "aws_route" "public-rt-igw" {
    route_table_id = aws_route_table.public-rt.id  # Associate the route with the public route table
    destination_cidr_block = "0.0.0.0/0"  # Route all traffic
    gateway_id = aws_internet_gateway.igw.id  # Use the internet gateway for the route
    depends_on = [aws_internet_gateway.igw]  # Ensure the internet gateway is created first
}

# Route for Private Subnets through NAT Gateway 
resource "aws_route" "private-rt-natgw-1" {
    route_table_id = aws_route_table.private-rt-1.id  # Associate the route with the first private route table
    destination_cidr_block = "0.0.0.0/0"  # Route all traffic
    nat_gateway_id = aws_nat_gateway.NATgw-1.id  # Use the first NAT gateway for the route
    depends_on = [aws_internet_gateway.igw]  # Ensure the internet gateway is created first
}

resource "aws_route" "private-rt-natgw-2" {
    route_table_id = aws_route_table.private-rt-2.id  # Associate the route with the second private route table
    destination_cidr_block = "0.0.0.0/0"  # Route all traffic
    nat_gateway_id = aws_nat_gateway.NATgw-2.id  # Use the second NAT gateway for the route
    depends_on = [aws_internet_gateway.igw]  # Ensure the internet gateway is created first
}

# Route Table Association of Subnets
# Public Route Table Association
resource "aws_route_table_association" "pub-Subnet-1-assoc" {
    route_table_id = aws_route_table.public-rt.id  # Associate the public route table with the first public subnet
    subnet_id = aws_subnet.public-subnets[0].id  # Specify the first public subnet
}

resource "aws_route_table_association" "pub-Subnet-2-assoc" {
    route_table_id = aws_route_table.public-rt.id  # Associate the public route table with the second public subnet
    subnet_id = aws_subnet.public-subnets[1].id  # Specify the second public subnet
}

# Private Route Table Association
resource "aws_route_table_association" "priv-subnet-1-assoc" {
    route_table_id = aws_route_table.private-rt-1.id  # Associate the first private route table with the first private subnet
    subnet_id = aws_subnet.private-subnets[0].id  # Specify the first private subnet
}

resource "aws_route_table_association" "priv-subnet-2-assoc" {
    route_table_id = aws_route_table.private-rt-2.id  # Associate the second private route table with the second private subnet
    subnet_id = aws_subnet.private-subnets[1].id  # Specify the second private subnet
}

/*
# Main Route Table Association - Associate Private Route Table to Main Route Table
resource "aws_main_route_table_association" "main_rtb_assoc" {
    vpc_id = aws_vpc.main.id  # Associate the main route table with the main VPC
    route_table_id = aws_route_table.private-rt-1.id  # Specify the private route table
}
*/
