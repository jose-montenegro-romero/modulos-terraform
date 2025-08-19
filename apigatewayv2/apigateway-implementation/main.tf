resource "aws_apigatewayv2_deployment" "apigatewayv2_deployment" {
  api_id      = var.api_id
  description = "Deployment ${timestamp()}"

  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_integration.apigatewayv2_integration),
      jsonencode(aws_apigatewayv2_route.apigatewayv2_route),
    ])))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_stage" "apigatewayv2_stage" {
  api_id        = var.api_id
  deployment_id = aws_apigatewayv2_deployment.apigatewayv2_deployment.id
  name          = var.api_stage_name
  # auto_deploy   = true
}

resource "aws_apigatewayv2_integration" "apigatewayv2_integration" {

  for_each = {
    for route in var.routes : route.path => route
  }

  api_id           = var.api_id
  integration_type = each.value.integration_type

  integration_method = each.value.integration_method
  integration_uri    = each.value.integration_uri
  connection_type    = try(each.value.vpc_link_enabled, false) ? "VPC_LINK" : null
  connection_id      = try(each.value.vpc_link_enabled, false) ? each.value.connection_id : null
}

resource "aws_apigatewayv2_route" "apigatewayv2_route" {

  for_each = {
    for route in var.routes : route.path => route
  }

  api_id             = var.api_id
  route_key          = "${each.value.integration_method} ${each.value.path}"
  api_key_required   = each.value.api_key_required
  authorization_type = each.value.authorization_type
  authorizer_id      = each.value.authorizer_id

  target = "integrations/${aws_apigatewayv2_integration.apigatewayv2_integration[each.key].id}"
}
