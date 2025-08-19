#Create Security group
resource "aws_security_group" "security_group" {
  name        = "security-group-${var.name}-${var.layer}-${var.stack_id}"
  description = replace("security group ${var.name} ${var.layer} ${var.stack_id}", "/[-_]/", " ")
  vpc_id      = var.vpc_id

  dynamic "ingress" {

    for_each = var.ingress

    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
    }
  }

  dynamic "egress" {

    for_each = var.egress

    content {
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
    }
  }

  tags = merge(var.tags, {
    Name        = "security-group-${var.name}-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}
