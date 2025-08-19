resource "aws_apigatewayv2_api" "apigatewayv2_api" {
  name        = replace("apigateway-${lookup(var.configuration_apigateway, "name")}-${var.layer}-${var.stack_id}", "_", "-")
  description = replace("Api gateway ${lookup(var.configuration_apigateway, "name")} ${var.layer} ${var.stack_id}", "/[-_]/", " ")

  protocol_type                = var.configuration_apigateway.protocol_type
  route_selection_expression   = var.configuration_apigateway.route_selection_expression
  ip_address_type              = var.configuration_apigateway.ip_address_type
  disable_execute_api_endpoint = var.configuration_apigateway.disable_execute_api_endpoint

  dynamic "cors_configuration" {
    for_each = var.configuration_apigateway.cors_configuration != null ? [var.configuration_apigateway.cors_configuration] : []

    content {
      allow_origins     = try(cors_configuration.value.allow_origins, null)
      allow_methods     = try(cors_configuration.value.allow_methods, null)
      allow_headers     = try(cors_configuration.value.allow_headers, null)
      expose_headers    = try(cors_configuration.value.expose_headers, null)
      max_age           = try(cors_configuration.value.max_age, null)
      allow_credentials = try(cors_configuration.value.allow_credentials, null)
    }
  }
}

///////////////////////////////////////////////////////////////////////
/////////////// VPC LINK       ////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

#Create LB
module "sg_lb" {
  source = "../sg"

  count = var.configuration_apigateway.enable_vpc_link ? 1 : 0

  layer    = var.layer
  stack_id = var.stack_id
  // configuration sg
  name    = var.configuration_apigateway.name
  vpc_id  = var.vpc_id
  ingress = var.configuration_apigateway.ingress
  egress  = var.configuration_apigateway.egress
  // TAGS
  tags = var.tags
}

resource "aws_apigatewayv2_vpc_link" "apigatewayv2_vpc_link" {

  count = var.configuration_apigateway.enable_vpc_link ? 1 : 0

  name               = replace("vpclink-v2-${var.configuration_apigateway.name}-${var.layer}-${var.stack_id}", "_", "-")
  security_group_ids = [module.sg_lb[0].sg_reference.id]
  subnet_ids         = var.subnets

  tags = merge(var.tags, {
    Name        = "vpclink-v2-${var.configuration_apigateway.name}-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}

