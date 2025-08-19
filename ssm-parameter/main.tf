resource "aws_ssm_parameter" "ssm_google_recaptcha_hermes" {
  name  = "/${var.stack_id}/${var.name}"
  type  = var.type
  value = var.value

  tags = merge(var.tags, {
    Name        = "/${var.stack_id}/${var.name}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}
