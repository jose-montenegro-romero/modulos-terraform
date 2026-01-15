resource "aws_lambda_permission" "allow_api_gateway_invoke_authorizer" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.execution_arn}/authorizers/${aws_api_gateway_authorizer.api_gateway_authorizer.id}" # Permite invocar desde cualquier método de la API
}

data "aws_iam_policy_document" "invocation_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "invocation_role" {
  name               = replace("auth-invocation-${var.configuration_authorizer.name}-${var.project}-${var.environment}", "_", "-")
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.invocation_assume_role.json
}

resource "aws_api_gateway_authorizer" "api_gateway_authorizer" {
  name            = replace("auth-${var.configuration_authorizer.name}-${var.project}-${var.environment}", "_", "-")
  identity_source = "method.request.header.Authorization"
  rest_api_id     = var.api_id
  authorizer_uri  = var.lambda_invoke_arn
  # authorizer_credentials           = aws_iam_role.invocation_role.arn
  authorizer_result_ttl_in_seconds = 300
}
