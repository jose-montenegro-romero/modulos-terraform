# Obtenemos la región actual para construir el Service Name
data "aws_region" "current" {}

resource "aws_vpc_endpoint" "vpc_endpoint_gateway_endpoints" {
  for_each          = var.endpoints
  
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type = "Gateway"

  # Asociación automática a las tablas de ruteo
  route_table_ids   = var.route_table_ids

  tags = merge(
    var.tags,
    {
      Name = "vpce-${each.value}-gateway-${var.project}-${var.environment}"
      Environment = var.environment
      Source      = "Terraform"
    }
  )
}