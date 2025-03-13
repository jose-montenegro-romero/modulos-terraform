locals {
  number_of_resources         = length(var.subnets_public)
  number_of_resources_private = length(var.subnets_private)
}

data "aws_availability_zones" "available" {
}

#vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name   = "vpc_${var.layer}_${var.stack_id}"
    Source = "Terraform"
  }
}

#public_subnets
resource "aws_subnet" "public_subnets" {
  count                   = local.number_of_resources
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnets_public[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name   = "${var.layer}_${var.stack_id}_subnet_public_${count.index + 1}"
    Source = "Terraform"
  }
}

#private_subnets
resource "aws_subnet" "private_subnets" {
  count             = local.number_of_resources_private
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets_private[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name   = "${var.layer}_${var.stack_id}_subnet_private_${count.index + 1}"
    Source = "Terraform"
  }
}

#internet_gateway
resource "aws_internet_gateway" "IG" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name   = "${var.layer}_${var.stack_id}_IG"
    Source = "Terraform"
  }
}

# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "elastic_ip" {

  count = local.number_of_resources

  vpc = true

  tags = {
    Name   = "${var.layer}_${var.stack_id}_eip_${count.index + 1}"
    Source = "Terraform"
  }
}

resource "aws_nat_gateway" "nat_gw" {

  count = local.number_of_resources_private

  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)
  allocation_id = element(aws_eip.elastic_ip.*.id, count.index)

  tags = {
    Name   = "${var.layer}_${var.stack_id}_nat_gateway_${count.index + 1}"
    Source = "Terraform"
  }
}

#routing tables public
resource "aws_route_table" "public_routing_table" {

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IG.id
  }
  tags = {
    Name   = "${var.layer}_${var.stack_id}_route_table_public"
    Source = "Terraform"
  }

}

#routing tables private
resource "aws_route_table" "private_routing_table" {

  count = local.number_of_resources_private

  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gw.*.id, count.index)
  }
  tags = {
    Name   = "${var.layer}_${var.stack_id}_route_table_private_${count.index + 1}"
    Source = "Terraform"
  }
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


