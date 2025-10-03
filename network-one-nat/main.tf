locals {
  number_of_resources            = length(var.subnets_public)
  number_of_resources_private    = length(var.subnets_private)
  number_of_resources_private_db = length(var.subnets_private_db)
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Ordena los nombres de las AZs para un orden predecible
  nombres_az_ordenados = sort(data.aws_availability_zones.available.names)
  # Selecciona zonas de disponibilidad
  azs_seleccionadas = slice(local.nombres_az_ordenados, 0, local.number_of_resources)
}

#vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, {
    Name        = "vpc-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}

#public_subnets
resource "aws_subnet" "public_subnets" {
  count                   = local.number_of_resources
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnets_public[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name        = "subnet-public-${var.layer}-${var.stack_id}-${count.index + 1}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}

#private_subnets
resource "aws_subnet" "private_subnets" {
  count = local.number_of_resources_private

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets_private[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name        = "subnet-private-${var.layer}-${var.stack_id}-${count.index + 1}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}

#private_subnets
resource "aws_subnet" "private_subnets_db" {
  count = local.number_of_resources_private_db

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets_private_db[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name        = "subnet-private-db-${var.layer}-${var.stack_id}-${count.index + 1}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}

#internet_gateway
resource "aws_internet_gateway" "IG" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(var.tags, {
    Name        = "IGW-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}

# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "elastic_ip" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name        = "eip-nat-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}

resource "aws_nat_gateway" "nat_gw" {

  subnet_id     = element(aws_subnet.public_subnets.*.id, 0)
  allocation_id = aws_eip.elastic_ip.id

  tags = merge(var.tags, {
    Name        = "nat-gateway-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}

#routing tables public
resource "aws_route_table" "public_routing_table" {

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IG.id
  }
  tags = merge(var.tags, {
    Name        = "route-table-public-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })

}

#routing tables private
resource "aws_route_table" "private_routing_table" {

  count = local.number_of_resources_private

  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  dynamic "route" {
    for_each = var.routes_private
    content {
      cidr_block         = route.value.cidr_block
      nat_gateway_id     = route.value.nat_gateway == false ? null : aws_nat_gateway.nat_gw.id
      transit_gateway_id = route.value.transit_gateway == false ? null : var.transit_gateway_id
    }
  }

  tags = merge(var.tags, {
    Name        = "route-table-private-${var.layer}-${var.stack_id}-${count.index + 1}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}

# aws_route_table_association public subnets
resource "aws_route_table_association" "public_subnets_routing_table_associations" {
  count          = local.number_of_resources
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_routing_table.id
}

# aws_route_table_association private subnets
resource "aws_route_table_association" "private_subnets_routing_table_associations" {
  count          = local.number_of_resources_private
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private_routing_table.*.id, count.index)
}

# aws_route_table_association private subnets DB
resource "aws_route_table_association" "private_subnets_db_routing_table_associations" {
  count          = local.number_of_resources_private_db
  subnet_id      = element(aws_subnet.private_subnets_db.*.id, count.index)
  route_table_id = element(aws_route_table.private_routing_table.*.id, count.index)
}

resource "aws_ec2_transit_gateway_vpc_attachment" "ec2_transit_gateway_vpc_attachment" {

  count = var.transit_gateway_id != null ? 1 : 0

  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.vpc.id
  subnet_ids         = aws_subnet.private_subnets[*].id

  tags = merge(var.tags, {
    Name        = "transit-gateway-vpc-ttachment-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}
