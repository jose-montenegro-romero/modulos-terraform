output "apigateway_reference" {
  value = aws_apigatewayv2_api.apigatewayv2_api
}

output "vpc_link_reference" {
  value = length(aws_apigatewayv2_vpc_link.apigatewayv2_vpc_link) > 0 ? aws_apigatewayv2_vpc_link.apigatewayv2_vpc_link[0] : null
  description = "VPC Link creado si se proporcionó un ARN de NLB"
}
