# IAM role for Lambda execution
data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_role" {
  name               = "lambda-execution-role-${var.configuration_lambda.name}-${var.layer}-${var.stack_id}"
  assume_role_policy = data.aws_iam_policy_document.iam_policy_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Package the Lambda function code
data "archive_file" "archive_file" {
  type        = "zip"
  source_dir  = var.configuration_lambda.source_dir
  output_path = "${path.module}/lambda/function.zip"
}

# Lambda function
resource "aws_lambda_function" "lambda_function" {
  filename         = data.archive_file.archive_file.output_path
  function_name    = "lambda-${var.configuration_lambda.name}-${var.layer}-${var.stack_id}"
  role             = aws_iam_role.iam_role.arn
  handler          = var.configuration_lambda.handler
  source_code_hash = data.archive_file.archive_file.output_base64sha256

  runtime     = var.configuration_lambda.runtime
  timeout     = var.configuration_lambda.timeout
  memory_size = var.configuration_lambda.memory_size

  # dynamic "vpc_config" {
  #   for_each = length(var.subnets) > 0 ? [1] : []
  #   content {
  #     subnet_ids         = var.subnets
  #     security_group_ids = [aws_security_group.example_lambda.id]
  #   }
  # }

  environment {
    variables = var.configuration_lambda.variables
  }

  tags = merge(var.tags, {
    Name        = "lambda-${var.configuration_lambda.name}-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}
