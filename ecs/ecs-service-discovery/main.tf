resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = var.namespace_name
  description = replace("Namespace ${var.namespace_name} ${var.stack_id}", "/[-_]/", " ")
  vpc         = var.vpc_id

  tags = merge(var.tags, {
    Name        = "namespace-${var.namespace_name}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}
