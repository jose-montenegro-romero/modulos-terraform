resource "aws_apigatewayv2_domain_name" "apigatewayv2_domain_name" {
  domain_name = var.configuration_custom_domain.domain_name

  domain_name_configuration {
    certificate_arn = var.configuration_custom_domain.certificate_arn
    endpoint_type   = var.configuration_custom_domain.endpoint_type
    security_policy = var.configuration_custom_domain.security_policy
  }

  tags = merge(var.tags, {
    Name        = "domain-name-${var.configuration_custom_domain.domain_name}-${var.project}-${var.environment}"
    Environment = var.environment
    Source      = "Terraform"
  })
}

resource "aws_apigatewayv2_api_mapping" "apigatewayv2_api_mapping" {
  api_id      = var.api_id
  domain_name = aws_apigatewayv2_domain_name.apigatewayv2_domain_name.id
  stage       = var.environment
}
