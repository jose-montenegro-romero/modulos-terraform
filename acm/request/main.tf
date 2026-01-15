resource "aws_acm_certificate" "acm_certificate_request" {

  domain_name               = lookup(var.configuration_acm, "domain_name")
  subject_alternative_names = lookup(var.configuration_acm, "subject_alternative_names")
  validation_method         = lookup(var.configuration_acm, "validation_method")

  tags = merge(var.tags, {
    Name        = "acm-${var.project}-${var.environment}"
    # Domain      = lookup(var.configuration_acm, "domain_name")
    Environment = var.environment
    Source      = "Terraform"
  })

  lifecycle {
    create_before_destroy = true
  }
}
