resource "aws_wafv2_ip_set" "ip_set_ipv4" {
  name               = var.name
  scope              = var.scope
  description        = var.description
  ip_address_version = var.ip_address_version
  addresses          = var.addresses
  tags               = var.tags
}
