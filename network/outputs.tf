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
