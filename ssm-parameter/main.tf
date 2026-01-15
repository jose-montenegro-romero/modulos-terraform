resource "aws_ssm_parameter" "ssm_google_recaptcha_hermes" {
  name  = "/${var.environment}/${var.name}"
  type  = var.type
  value = var.value

  tags = merge(var.tags, {
    Name        = "/${var.environment}/${var.name}"
    Environment = var.environment
    Source      = "Terraform"
  })
}
