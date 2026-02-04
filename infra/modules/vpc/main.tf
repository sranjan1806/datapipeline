data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

# Guardrails: ensure counts match
resource "null_resource" "validate_subnet_counts" {
  lifecycle {
    precondition {
      condition     = length(var.public_subnet_cidrs) == var.az_count
      error_message = "public_subnet_cidrs length must match az_count"
    }
    precondition {
      condition     = length(var.private_subnet_cidrs) == var.az_count
      error_message = "private_subnet_cidrs length must match az_count"
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.name}-igw" }
}

# Public subnets
resource "aws_subnet" "public" {
  for_each = { for i, az in local.azs : i => az }

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value
  cidr_block              = var.public_subnet_cidrs[each.key]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-${each.value}"
    Tier = "public"
  }

  depends_on = [null_resource.validate_subnet_counts]
}

# Private subnets
resource "aws_subnet" "private" {
  for_each = { for i, az in local.azs : i => az }

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value
  cidr_block        = var.private_subnet_cidrs[each.key]

  tags = {
    Name = "${var.name}-private-${each.value}"
    Tier = "private"
  }

  depends_on = [null_resource.validate_subnet_counts]
}

# Public route table -> IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-public-rt" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# NAT gateway (single NAT)
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.name}-nat-eip" }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id
  tags          = { Name = "${var.name}-nat" }

  depends_on = [aws_internet_gateway.this]
}

# Private route table -> NAT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-private-rt" }
}

resource "aws_route" "private_to_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
