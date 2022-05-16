terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "aws_region" {
    default = "us-west-2"
}

variable "base_cidr_block" {
  description = "A /16 CIDR range definition, such as 10.1.0.0/16, that the VPC will use"
  default = "172.44.0.0/16"
}

variable "availability_zones" {
  description = "A list of availability zones in which to create subnets"
  type = list("us-west-2a","us-west-2b","us-west-2c")
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "jmi_terraform_vpc" {
  cidr_block = var.base_cidr_block
}

resource "aws_internet_gateway" "ig_jmi" {
  vpc_id = aws_vpc.jmi_terraform_vpc.id
  tags = {
    Name        = "internet_gateway_jmi"
  }
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.id]
}

resource "aws_nat_gateway" "nat_jmi" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet_jmi.*.id, 0)

  tags = {
    Name        = "nat_jmi"
  }
}

resource "aws_subnet" "public_subnet_jmi" {
  # Create one subnet for each given availability zone.
  count = length(var.availability_zones)
  # For each subnet, use one of the specified availability zones.
  availability_zone = var.availability_zones[count.index]

  vpc_id = aws_vpc.jmi_terraform_vpc.id

  cidr_block = cidrsubnet(aws_vpc.jmi_terraform_vpc.cidr_block, 4, count.index+1)
  tags = {
    Name = "jmi-public-subnet-${count.index}"
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
    Name = "jmi-private-subnet-${count.index}"
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
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}