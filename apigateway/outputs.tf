output "apigateway_reference" {
  value = aws_api_gateway_rest_api.api_gateway_rest_api
}

output "vpc_link_reference" {
  value = length(aws_api_gateway_vpc_link.api_gateway_vpc_link) > 0 ? aws_api_gateway_vpc_link.api_gateway_vpc_link[0] : null
  description = "VPC Link creado si se proporcionó un ARN de NLB"
}
