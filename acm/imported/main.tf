resource "aws_acm_certificate" "acm_certificate_imported" {
  private_key       = file(lookup(var.configuration_acm, "private_key"))
  certificate_body  = file(lookup(var.configuration_acm, "certificate_body"))
  certificate_chain = lookup(var.configuration_acm, "certificate_chain") != null ? file(lookup(var.configuration_acm, "certificate_chain")) : null

  tags = merge(var.tags, {
    Name        = "acm-${var.layer}-${var.stack_id}"
    Domain      = lookup(var.configuration_acm, "domain")
    Environment = var.stack_id
    Source      = "Terraform"
  })
}
