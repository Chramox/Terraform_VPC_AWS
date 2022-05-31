resource "aws_vpc" "jmi_terraform_vpc" {
  cidr_block = var.base_cidr_block
  tags = {
    Name = "vpc_jmi_tf"
  }
}

resource "aws_internet_gateway" "ig_jmi" {
  vpc_id = aws_vpc.jmi_terraform_vpc.id
  tags = {
    Name        = "internet_gateway_jmi_tf"
  }
}

resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.ig_jmi]
}

resource "aws_nat_gateway" "nat_jmi" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet_jmi.*.id, 0)
  tags = {
    Name        = "nat_jmi_tf"
  }
}

resource "aws_subnet" "private_subnet_jmi" {
  # Create one subnet for each given availability zone.
  count = length(var.availability_zones)
  # For each subnet, use one of the specified availability zones.
  availability_zone = var.availability_zones[count.index]

  vpc_id = aws_vpc.jmi_terraform_vpc.id

  cidr_block = cidrsubnet(aws_vpc.jmi_terraform_vpc.cidr_block, 4, count.index+1)
  tags = {
    Name = "jmi-private-subnet-${count.index}-tf"
  }
}

resource "aws_subnet" "public_subnet_jmi" {
  # Create one subnet for each given availability zone.
  count = length(var.availability_zones)
  # For each subnet, use one of the specified availability zones.
  availability_zone = var.availability_zones[count.index]

  vpc_id = aws_vpc.jmi_terraform_vpc.id

  cidr_block = cidrsubnet(aws_vpc.jmi_terraform_vpc.cidr_block, 4, count.index + length(var.availability_zones) + 1)
  tags = {
    Name = "jmi-public-subnet-${count.index}-tf"
  }
}

# Routing table - Private Subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.jmi_terraform_vpc.id

  tags = {
    Name = "jmi-private-route-table-tf"
  }
}

# Routing tables - Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.jmi_terraform_vpc.id

  tags = {
    Name = "jmi-public-route-table-tf"
  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig_jmi.id
}

# Route table associations
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.public_subnet_jmi.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.private_subnet_jmi.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}