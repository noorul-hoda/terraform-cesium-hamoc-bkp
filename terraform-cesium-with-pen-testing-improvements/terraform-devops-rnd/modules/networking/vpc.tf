## VPC
//Create Public & Private subnets,
//Internet Gateway,
//Route-tables, Route-table association,
//Elastic IP,
//NAT-gateway & NAT-G-route
//VPC

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = "true" #gives you an internal hostname
  enable_dns_support   = "true" #gives you an internal domain name
  enable_classiclink   = "false"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-vpc-${local.suffix}" }
    )
  )
}

#Public

resource "aws_subnet" "public-subnet" {
  #count                   = local.suffix == "prod" ? 3 : 1
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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-igw-${local.suffix}" }
    )
  )
}

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
  #count          = local.suffix == "prod" ? 3 : 1
  count          = length(var.pub-subnet)
  subnet_id      = element(aws_subnet.public-subnet.*.id, count.index)
  route_table_id = aws_route_table.rt-public.id
}

##Private

resource "aws_eip" "eip" {
  vpc = true
  #count = local.suffix == "prod" ? 3 : 1 //Commenting since only one nat gw needed
  tags = merge(
    local.common_tags,
    //Commenting since only one nat gw needed
    #tomap({ "Name" = "${local.prefix}-${data.aws_availability_zones.available.names[count.index]}-eip-${local.suffix}" }
    tomap({ "Name" = "${local.prefix}-eip-${local.suffix}" }
    )
  )
}

resource "aws_subnet" "private-subnet" {
  count                   = length(var.priv-subnet)
  cidr_block              = element(var.priv-subnet, count.index)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "false"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-subnet-${data.aws_availability_zones.available.names[count.index]}-${local.suffix}" }
    )
  )
}

resource "aws_nat_gateway" "nat-gateway" {
  #count         = local.suffix == "prod" ? 3 : 1 //Commenting since only one nat gw needed

  #allocation_id = element(aws_eip.eip.*.id, count.index)
  #subnet_id     = element(aws_subnet.public-subnet.*.id, count.index)

  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-subnet[0].id

  tags = merge(
    local.common_tags,
    //Commenting since only one nat gw needed
    #tomap({ "Name" = "${local.prefix}-nat-gateway-${data.aws_availability_zones.available.names[count.index]}-${local.suffix}" }
    tomap({ "Name" = "${local.prefix}-nat-gateway-${local.suffix}" }
    )
  )
}

resource "aws_route_table" "rt-private" {
  #count  = length(var.priv-subnet) //Commenting since only one nat gw needed

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-rt-private-${local.suffix}" }
    )
  )
}

resource "aws_route" "r-private" {
  //Commenting since only one nat gw needed
  #count          = local.suffix == "prod" ? 3 : 3
  #route_table_id = element(aws_route_table.rt-private.*.id, count.index)
  #nat_gateway_id         = local.suffix == "prod" ? element(aws_nat_gateway.nat-gateway.*.id, count.index) : aws_nat_gateway.nat-gateway[0].id 
  //
  route_table_id         = aws_route_table.rt-private.id
  nat_gateway_id         = aws_nat_gateway.nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "rta-private" {
  count          = length(var.priv-subnet)
  subnet_id      = element(aws_subnet.private-subnet.*.id, count.index)
  route_table_id = aws_route_table.rt-private.id
  #route_table_id = element(aws_route_table.rt-private.*.id, count.index)   //Commenting since only one nat gw needed
}

##Old code

# locals {
#   az_names = data.aws_availability_zones.available.names
# }
# resource "aws_subnet" "public-subnet-1" {
#   cidr_block              = var.pub-subnet
#   vpc_id                  = aws_vpc.vpc.id
#   map_public_ip_on_launch = "true" #It will make this public subnet
#   availability_zone       = var.zone2a

#   tags = merge(
#     local.common_tags,
#     # map("Name", "${local.prefix}-public-subnet-1-${local.suffix}"
#     # )
#     tomap({"Name" = "${local.prefix}-public-subnet-1-${local.suffix}"}
#     )
#   )
# }

# resource "aws_subnet" "public-subnet" {
#   for_each                = toset(var.pub-subnet)
#   #cidr_block              = each.key
#   cidr_block              = each.value
#   vpc_id                  = aws_vpc.vpc.id
#   map_public_ip_on_launch = "true" #It will make this public subnet
#   availability_zone       = element(data.aws_availability_zones.available.names)

#   tags = merge(
#     local.common_tags,
#     # map("Name", "${local.prefix}-public-subnet-1-${local.suffix}"
#     # )
#     tomap({ "Name" = "${local.prefix}-public-subnet-${local.suffix}" }
#     )
#   )
# }

# resource "aws_subnet" "private-subnet-1" {
#   cidr_block              = var.priv-subnet-1
#   vpc_id                  = aws_vpc.vpc.id
#   map_public_ip_on_launch = "false"
#   availability_zone       = var.zone2a

#   tags = merge(
#     local.common_tags,
#     # map("Name", "${local.prefix}-private-subnet-1-${local.suffix}"
#     # )
#     tomap({"Name" = "${local.prefix}-private-subnet-1-${local.suffix}"}
#     )
#   )
# }

# resource "aws_subnet" "private-subnet-2" {
#   cidr_block              = var.priv-subnet-2
#   vpc_id                  = aws_vpc.vpc.id
#   map_public_ip_on_launch = "false"
#   availability_zone       = var.zone2b

#   tags = merge(
#     local.common_tags,
#     # map("Name", "${local.prefix}-private-subnet-2-${local.suffix}"
#     # )
#     tomap({"Name" = "${local.prefix}-private-subnet-2-${local.suffix}"}
#     ) 
#   )
# }

# resource "aws_nat_gateway" "nat-gateway" {
#   allocation_id = aws_eip.eip.id
#   subnet_id     = aws_subnet.public-subnet-1.id

#   tags = merge(
#     local.common_tags,
#     # map("Name", "${local.prefix}-nat-gateway-${local.suffix}"
#     # )
#     tomap({"Name" = "${local.prefix}-nat-gateway-${local.suffix}"}
#     )
#   )
# }

# resource "aws_route" "r-private" {
#   route_table_id         = aws_route_table.rt-private.id
#   nat_gateway_id         = aws_nat_gateway.nat-gateway.id
#   destination_cidr_block = "0.0.0.0/0"
# }
# resource "aws_route_table_association" "rta-private" {
#   subnet_id      = aws_subnet.private-subnet-1.id
#   route_table_id = aws_route_table.rt-private.id

# }


# resource "aws_ssm_parameter" "vpc-id" {
#   name  = "/${local.prefix}/${local.suffix}/vpc-id"
#   type  = "String"
#   value = aws_vpc.vpc.id
# }

# resource "aws_ssm_parameter" "priv-1-sub-id" {
#   name  = "/${local.prefix}/${local.suffix}/priv-1-sub-id"
#   type  = "String"
#   value = aws_subnet.private-subnet-1.id
# }
# resource "aws_ssm_parameter" "priv-2-sub-id" {
#   name  = "/${local.prefix}/${local.suffix}/priv-2-sub-id"
#   type  = "String"
#   value = aws_subnet.private-subnet-2.id
# }




