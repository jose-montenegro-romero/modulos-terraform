resource "aws_wafv2_ip_set" "ip_set_ipv4" {
  name               = replace("${var.name}-${var.layer}-${var.stack_id}", "_", "-")
  description        = replace("${var.name} ${var.layer} ${var.stack_id}", "/[-_]/", " ")
  scope              = var.scope
  ip_address_version = var.ip_address_version
  addresses          = var.addresses
  tags               = var.tags
}
