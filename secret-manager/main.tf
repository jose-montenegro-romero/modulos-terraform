resource "random_password" "random_password" {

  count = var.random == true ? 1 : 0

  length           = 16
  special          = true
  override_special = "#%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "secretsmanager_secret_1" {
  name = var.name

  tags = merge(var.tags, {
    Name        = "${var.name}-${var.stack_id}-${var.layer}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}

resource "aws_secretsmanager_secret_version" "secretsmanager_secret_version_1" {
  secret_id     = aws_secretsmanager_secret.secretsmanager_secret_1.id
  secret_string = var.random == true ? random_password.random_password[0].result : var.value
}
