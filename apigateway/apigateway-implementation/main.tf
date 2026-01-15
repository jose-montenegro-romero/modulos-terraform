locals {
  route_parts = flatten([
    for route in var.routes : [
      for i in range(1, length(split("/", route.path)) + 1) : {
        full_path   = join("/", slice(split("/", route.path), 0, i))
        path_part   = split("/", route.path)[i - 1]
        parent_path = i == 1 ? null : join("/", slice(split("/", route.path), 0, i - 1))
      }
    ]
  ])

  all_unique_paths = {
    for rp in local.route_parts :
    rp.full_path => rp
    if(
      rp.path_part != ""
    )
  }

  root_resources = {
    for k, v in local.all_unique_paths : k => v
    if v.parent_path == null
  }

  child_resources = {
    for k, v in local.all_unique_paths : k => v
    if v.parent_path != null
  }
}

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  rest_api_id = var.api_gateway_rest_api_id

  triggers = {
    redeployment = timestamp()
    # redeployment = sha1(jsonencode([
    #   aws_api_gateway_resource.root_resources,
    #   aws_api_gateway_resource.child_resources,
    #   aws_api_gateway_method.methods,
    #   aws_api_gateway_integration.integrations,
    # ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_gateway_stage" {
  rest_api_id   = var.api_gateway_rest_api_id
  deployment_id = aws_api_gateway_deployment.api_gateway_deployment.id
  stage_name    = var.environment

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_cloudwatch_log_group.arn
    # Formato de logs de acceso. Puedes personalizarlo con variables $context.
    # Un formato JSON es muy útil para el análisis.
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      caller         = "$context.identity.caller"
      user           = "$context.identity.user"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      error          = "$context.error.message"
    })
  }
}

# Crea recursos de API Gateway para los padres
resource "aws_api_gateway_resource" "root_resources" {
  for_each = local.root_resources

  rest_api_id = var.api_gateway_rest_api_id
  path_part   = each.value.path_part
  parent_id   = var.api_gateway_rest_api_root_resource_id
}

resource "aws_api_gateway_resource" "child_resources" {
  for_each = local.child_resources

  rest_api_id = var.api_gateway_rest_api_id
  path_part   = each.value.path_part
  parent_id = try(
    aws_api_gateway_resource.root_resources[each.value.parent_path].id,
    var.api_gateway_rest_api_root_resource_id
  )
}

# Crea métodos y sus integraciones
resource "aws_api_gateway_method" "methods" {
  for_each = {
    for route in var.routes : route.path => route
  }

  rest_api_id = var.api_gateway_rest_api_id
  resource_id = coalesce(
    try(aws_api_gateway_resource.root_resources[each.key].id, null),
    try(aws_api_gateway_resource.child_resources[each.key].id, null)
  )
  http_method      = each.value.http_method
  authorization    = each.value.authorization
  authorizer_id    = each.value.authorizer_id
  api_key_required = lookup(each.value, "api_key_required", false)

  request_parameters = try(each.value.request_parameters_method, {})
}

resource "aws_api_gateway_integration" "integrations" {
  for_each = {
    for route in var.routes : route.path => route
  }

  rest_api_id = var.api_gateway_rest_api_id
  resource_id = coalesce(
    try(aws_api_gateway_resource.root_resources[each.key].id, null),
    try(aws_api_gateway_resource.child_resources[each.key].id, null)
  )
  http_method = aws_api_gateway_method.methods[each.key].http_method

  integration_http_method = try(each.value.integration_http_method, each.value.http_method)
  type                    = each.value.integration_type
  uri                     = try(each.value.integration_uri, null)

  request_parameters = try(each.value.request_parameters, {})
  request_templates  = try(each.value.request_templates, {})

  connection_type = try(each.value.vpc_link_enabled, false) ? "VPC_LINK" : null
  connection_id   = try(each.value.vpc_link_enabled, false) ? each.value.connection_id : null
}

resource "aws_api_gateway_method_response" "api_gateway_method_response" {

  for_each = {
    for route in var.routes : route.path => route
  }

  rest_api_id = var.api_gateway_rest_api_id
  resource_id = coalesce(
    try(aws_api_gateway_resource.root_resources[each.key].id, null),
    try(aws_api_gateway_resource.child_resources[each.key].id, null)
  )
  http_method = each.value.http_method
  status_code = "200"

  response_parameters = try(each.value.response_parameters, null)

}

# resource "aws_api_gateway_integration_response" "aws_api_gateway_integration_response" {

#   for_each = {
#     for route in var.routes : route.path => route
#   }

#   rest_api_id = var.api_gateway_rest_api_id
#   resource_id = coalesce(
#     try(aws_api_gateway_resource.root_resources[each.key].id, null),
#     try(aws_api_gateway_resource.child_resources[each.key].id, null)
#   )
#   http_method = each.value.http_method
#   status_code = aws_api_gateway_method_response.proxy_options_method_response.status_code

#   response_templates = {
#     "application/json" = ""
#   }

#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'",
#     "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST,PUT,DELETE,PATCH,HEAD'", # Ajusta según los métodos que uses
#     "method.response.header.Access-Control-Allow-Origin"  = "'*'"                                       # Ajusta al dominio de tu frontend
#   }
#   depends_on = [
#     aws_api_gateway_method_response.api_gateway_method_response
#   ]
# }
