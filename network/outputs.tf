output "vpc" {
  value = aws_vpc.vpc
}

output "subnets_public" {
  value = aws_subnet.public_subnets[*].id
}

output "subnets_private" {
  value = aws_subnet.private_subnets[*].id
}

output "subnets_private_db" {
  value = aws_subnet.private_subnets_db[*].id
}

output "nombres_az_seleccionados" {
  value = local.azs_seleccionadas
}

output "route_table_public_ids" {
  value = aws_route_table.public_routing_table[*].id
}

output "route_table_private_ids" {
  value = aws_route_table.private_routing_table[*].id
}