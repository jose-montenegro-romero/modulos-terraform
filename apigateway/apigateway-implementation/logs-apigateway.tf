resource "aws_cloudwatch_log_group" "api_cloudwatch_log_group" {
  name              = "/aws/api-gateway/${var.api_gateway_rest_api_name}/access"
  retention_in_days = 7
}

resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name = "api-gateway-cloudwatch-logging-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
    ]
  })
}

# 6. Política de IAM para permitir escribir en CloudWatch Logs
resource "aws_iam_role_policy" "api_gateway_cloudwatch_policy" {
  name = "api-gateway-cloudwatch-logs-policy"
  role = aws_iam_role.api_gateway_cloudwatch_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Esto asocia el rol de CloudWatch a nivel de cuenta/región
resource "aws_api_gateway_account" "my_api_account_settings" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_role.arn
}

resource "aws_api_gateway_method_settings" "all_methods_settings" {
  rest_api_id = var.api_gateway_rest_api_id
  stage_name  = aws_api_gateway_stage.api_gateway_stage.stage_name
  method_path = "*/*" # Aplica a todos los métodos en todas las rutas

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = false
  }
}
