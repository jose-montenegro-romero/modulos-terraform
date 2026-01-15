data "aws_region" "current" {}

# Security Group para permitir tráfico hacia los Endpoints
resource "aws_security_group" "security_group_interface_sg" {
  name        = "sg-vpc-interface-endpoints-${var.project}-${var.environment}"
  description = "Permite trafico HTTPS hacia los endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  tags = merge(
    var.tags,
    {
      Name = "sg-vpc-interface-endpoints-${var.project}-${var.environment}"
      Environment = var.environment
      Source      = "Terraform"
    }
  )
}

# Creación dinámica de los Endpoints
resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each = var.endpoints

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type = "Interface"

  subnet_ids          = var.subnet_ids
  security_group_ids  = [aws_security_group.security_group_interface_sg.id]
  
  # Importante para que las apps usen la URL estándar de AWS
  private_dns_enabled = true

  tags = merge(
    var.tags,
    {
      Name = "vpce-${each.value}-interface-${var.project}-${var.environment}"
      Environment = var.environment
      Source      = "Terraform"
    }
  )
}