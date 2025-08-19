# Permiso para que API Gateway invoque la Lambda
resource "aws_lambda_permission" "apigateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.execution_arn}/*/*"
}

resource "aws_apigatewayv2_authorizer" "apigatewayv2_authorizer" {
  name                              = replace("auth-${var.configuration_authorizer.name}-${var.layer}-${var.stack_id}", "_", "-")
  api_id                            = var.api_id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = var.lambda_invoke_arn
  identity_sources                  = var.configuration_authorizer.identity_sources
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = var.configuration_authorizer.enable_simple_responses
  authorizer_result_ttl_in_seconds  = var.configuration_authorizer.authorizer_result_ttl_in_seconds
}
