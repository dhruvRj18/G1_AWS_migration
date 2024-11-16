resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}


resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_a  # Update with a new CIDR block, e.g., "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_b  # Update with a second CIDR block, e.g., "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr
}
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}
# NAT Gateway in Public Subnet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id  # Use one of your public subnets
}
# Route Table for Private Subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}
# Associate Route Table with Private Subnet
resource "aws_route_table_association" "private_route_table_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_association_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_route_table.id
}



#VPN resources

# Create a Virtual Private Gateway (VGW)
resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = aws_vpc.main.id
}

# Customer Gateway (on-premises endpoint)
resource "aws_customer_gateway" "onprem" {
  bgp_asn    = 65000
  ip_address = "142.156.1.223"
  type       = "ipsec.1"
}

# VPN Connection
resource "aws_vpn_connection" "vpn_connection" {
  customer_gateway_id = aws_customer_gateway.onprem.id
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
  type                = "ipsec.1"
  static_routes_only  = true
}

# Private Route Table entry to route on-premises traffic to VGW
resource "aws_route" "to_onprem" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "10.173.54.0/24"
  gateway_id             = aws_vpn_gateway.vpn_gateway.id
}


