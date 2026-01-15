resource "aws_db_parameter_group" "db_paramgroup" {
  name   = "${var.identifier}-pg"
  family = var.family

  tags = {
    Name = "${var.identifier}-pg"
  }
  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.identifier}-subnetgroup"
  subnet_ids = var.subnet_ids
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "#%&*()-_=+[]{}<>:?"
}

resource "aws_db_instance" "rds" {
  max_allocated_storage        = var.max_allocated_storage
  allocated_storage            = var.allocated_storage       # gigabytes
  backup_retention_period      = var.backup_retention_period # in days
  db_subnet_group_name         = aws_db_subnet_group.rds.id
  engine                       = var.engine
  engine_version               = var.engine_version
  identifier                   = var.identifier
  instance_class               = var.instances_type
  multi_az                     = var.multi_az
  db_name                      = var.db_name
  parameter_group_name         = aws_db_parameter_group.db_paramgroup.name
  password                     = random_password.password.result
  port                         = var.rds_port
  publicly_accessible          = var.publicly_accessible # change to false
  storage_encrypted            = var.storage_encrypted   # change to true
  storage_type                 = var.storage_type
  username                     = var.user_name
  vpc_security_group_ids       = var.security_group
  performance_insights_enabled = var.performance_insights_enabled
  skip_final_snapshot          = var.skip_final_snapshot
  deletion_protection          = var.deletion_protection

  tags = merge(var.tags, {
    Name        = "${var.db_name}-${var.project}-${var.environment}"
    Environment = var.environment
    Source      = "Terraform"
  })

  depends_on = [
    aws_db_parameter_group.db_paramgroup,
    aws_db_subnet_group.rds
  ]
}

resource "aws_ssm_parameter" "secret_password" {
  name  = "/${var.identifier}/DB_PASSWORD"
  type  = "SecureString"
  value = random_password.password.result

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_user" {
  name  = "/${var.identifier}/DB_USERNAME"
  type  = "SecureString"
  value = var.user_name

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_database" {
  name  = "/${var.identifier}/DB_DATABASE"
  type  = "SecureString"
  value = var.db_name

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_port" {
  name  = "/${var.identifier}/DB_PORT"
  type  = "SecureString"
  value = aws_db_instance.rds.port

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_host" {
  name  = "/${var.identifier}/DB_HOST"
  type  = "SecureString"
  value = aws_db_instance.rds.endpoint

  tags = {
    Source = "Terraform"
  }
}
