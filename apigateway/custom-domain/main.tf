resource "aws_api_gateway_domain_name" "api_gateway_domain_name" {
  domain_name              = lookup(var.configuration_custom_domain, "domain_name")
  regional_certificate_arn = lookup(var.configuration_custom_domain, "regional_certificate_arn")

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "custom_domain_mapping" {
  api_id      = lookup(var.configuration_custom_domain, "api_id")
  stage_name  = var.stack_id
  domain_name = aws_api_gateway_domain_name.api_gateway_domain_name.domain_name
}
