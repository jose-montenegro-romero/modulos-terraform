resource "aws_api_gateway_rest_api" "api_gateway_rest_api" {
  name        = replace("apigateway-${lookup(var.configuration_apigateway, "name")}-${var.layer}-${var.stack_id}", "_", "-")
  description = replace("Api gateway ${lookup(var.configuration_apigateway, "name")} ${var.layer} ${var.stack_id}", "/[-_]/", " ")

  binary_media_types           = var.configuration_apigateway.binary_media_types
  body                         = lookup(var.configuration_apigateway, "body", null)
  disable_execute_api_endpoint = lookup(var.configuration_apigateway, "disable_execute_api_endpoint", null)

  endpoint_configuration {
    types            = lookup(var.configuration_apigateway, "endpoint_configuration_types", ["REGIONAL"])
    vpc_endpoint_ids = lookup(var.configuration_apigateway, "endpoint_configuration_vpc_endpoint_ids", null)
  }

  lifecycle {
    ignore_changes = [
      description,
      name,
    ]
  }

  tags = merge(var.tags, {
    Name        = "apigateway-${lookup(var.configuration_apigateway, "name")}-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })

}

resource "aws_api_gateway_rest_api_policy" "api_gateway_rest_api_policy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "execute-api:Invoke",
        "Resource": ["${aws_api_gateway_rest_api.api_gateway_rest_api.execution_arn}/*"]
      }
    ]
  }
  EOF
}

resource "aws_api_gateway_vpc_link" "api_gateway_vpc_link" {

  count = var.configuration_apigateway.enable_vpc_link ? 1 : 0

  name        = replace("vpclink-${lookup(var.configuration_apigateway, "name")}-${var.layer}-${var.stack_id}", "_", "-")
  target_arns = [var.configuration_apigateway.vpc_link_nlb_arn]

  tags = merge(var.tags, {
    Name        = "vpclink-${lookup(var.configuration_apigateway, "name")}-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}

///////////////////////////////////////////////////////////////////////
/////////////// Create Api Key ////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

resource "aws_api_gateway_api_key" "api_gateway_api_key" {
  count = var.api_key_config.enabled ? 1 : 0

  name        = replace("api-key-${lookup(var.configuration_apigateway, "name")}-${var.layer}-${var.stack_id}", "_", "-")
  description = replace("Api Key ${lookup(var.configuration_apigateway, "name")} ${var.layer} ${var.stack_id}", "/[-_]/", " ")
  enabled     = true
}

resource "aws_api_gateway_usage_plan" "api_gateway_usage_plan" {
  count = var.api_key_config.enabled ? 1 : 0

  name = replace("usage-plan-key-${lookup(var.configuration_apigateway, "name")}-${var.layer}-${var.stack_id}", "_", "-")

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
    stage  = var.stack_id
  }

  throttle_settings {
    rate_limit  = try(var.api_key_config.usage_plan.throttle.rate_limit, 10)
    burst_limit = try(var.api_key_config.usage_plan.throttle.burst_limit, 2)
  }

  quota_settings {
    limit  = try(var.api_key_config.usage_plan.quota.limit, 1000)
    period = try(var.api_key_config.usage_plan.quota.period, "MONTH")
  }
}

resource "aws_api_gateway_usage_plan_key" "api_gateway_usage_plan_key" {
  count = var.api_key_config.enabled ? 1 : 0

  key_id        = aws_api_gateway_api_key.api_gateway_api_key[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_gateway_usage_plan[0].id
}
