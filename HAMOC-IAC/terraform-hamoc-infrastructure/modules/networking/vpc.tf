##VPC

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
  enable_classiclink   = "false"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-vpc-${local.suffix}" }
    )
  )
}

##Public Subnet

resource "aws_subnet" "public-subnet" {
  count                   = length(var.pub-subnet)
  cidr_block              = element(var.pub-subnet, count.index)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-subnet-${data.aws_availability_zones.available.names[count.index]}-${local.suffix}" }
    )
  )
}

##Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-igw-${local.suffix}" }
    )
  )
}

##Public Route table

resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-rt-public-${local.suffix}" }
    )
  )
}

resource "aws_route" "r-public" {
  route_table_id         = aws_route_table.rt-public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "rta-public" {
  count          = length(var.pub-subnet)
  subnet_id      = element(aws_subnet.public-subnet.*.id, count.index)
  route_table_id = aws_route_table.rt-public.id
}

##Nat EIP

resource "aws_eip" "nat" {
  count = var.single_nat_gateway ? 1 : length(var.priv-subnet)
  vpc = true
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${element((data.aws_availability_zones.available.names), count.index)}-eip-nat-${local.suffix}" })
    )
}

##Private Subnet

resource "aws_subnet" "private-subnet" {
  count                   = length(var.priv-subnet)
  cidr_block              = element(var.priv-subnet, count.index)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "false"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-subnet-${element((data.aws_availability_zones.available.names), count.index)}-${local.suffix}" }
    )
  )
}

##Nat GW

resource "aws_nat_gateway" "nat-gateway" {
  count = var.single_nat_gateway ? 1 : length(var.priv-subnet)
  # allocation_id = element(
  #   aws_eip.nat.*.id, 
  #   var.single_nat_gateway ? 0 : count.index,
  # )
  # subnet_id = element(
  #   aws_subnet.public-subnet.*.id,
  #   var.single_nat_gateway ? 0 : count.index,
  # )
  allocation_id = element(
    aws_eip.nat.*.id, count.index,
  )
  subnet_id = element(
    aws_subnet.public-subnet.*.id, count.index,
  )
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-nat-gateway-${element((data.aws_availability_zones.available.names), count.index)}-${local.suffix}" }
    )
  )
}

##Private Route table

resource "aws_route_table" "rt-private" {
  count  = var.single_nat_gateway ? 1 : length(var.priv-subnet)

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-rt-private-${element((data.aws_availability_zones.available.names), count.index)}-${local.suffix}" }
    )
  )
}

resource "aws_route" "r-private" {
  count                  = var.single_nat_gateway ? 1 : length(var.priv-subnet)
  route_table_id         = element(aws_route_table.rt-private.*.id, count.index)
  nat_gateway_id         = element(aws_nat_gateway.nat-gateway.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "rta-private" {
  count          = length(var.priv-subnet)
  subnet_id      = element(aws_subnet.private-subnet.*.id, count.index)
  route_table_id = element(aws_route_table.rt-private.*.id, count.index)
}