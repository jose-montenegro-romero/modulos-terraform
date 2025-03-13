resource "aws_security_group" "sg_db" {
  name        = "sgDb_${lookup(var.configuration_rds, "rds_name")}_${var.layer}_${var.stack_id}"
  vpc_id      = var.vpc
  description = "Enable access to the RDS DB"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "db_${lookup(var.configuration_rds, "rds_name")}_${var.layer}_${var.stack_id}"
    Source = "Terraform"
  }
}

resource "aws_db_subnet_group" "default_subnet_rds" {
  name        = "subnet_rds_${lookup(var.configuration_rds, "rds_name")}_${var.layer}_${var.stack_id}"
  description = "subnet_rds_${lookup(var.configuration_rds, "rds_name")}_${var.layer}_${var.stack_id}"
  subnet_ids  = var.db_subnets_private

  tags = {
    Name   = "DB_${lookup(var.configuration_rds, "rds_name")}_${var.layer}_${var.stack_id}"
    Source = "Terraform"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "#%&*()-_=+[]{}<>:?"
}

resource "aws_rds_cluster" "db" {
  cluster_identifier      = replace("${lookup(var.configuration_rds, "rds_name")}-${var.layer}-${var.stack_id}", "_", "-")
  engine                  = lookup(var.configuration_rds, "engine", "aurora-mysql")
  engine_mode             = lookup(var.configuration_rds, "engine_mode", "serverless")
  engine_version          = lookup(var.configuration_rds, "engine_version", null)
  database_name           = lookup(var.configuration_rds, "database_name")
  master_username         = lookup(var.configuration_rds, "master_username")
  master_password         = random_password.password.result
  vpc_security_group_ids  = ["${aws_security_group.sg_db.id}"]
  db_subnet_group_name    = aws_db_subnet_group.default_subnet_rds.name
  backup_retention_period = lookup(var.configuration_rds, "backup_retention_period", 7)
  preferred_backup_window = lookup(var.configuration_rds, "preferred_backup_window", "23:00-00:00")
  deletion_protection     = lookup(var.configuration_rds, "deletion_protection", true)

  scaling_configuration {
    auto_pause               = lookup(var.configuration_rds.scaling_configuration, "auto_pause", true)
    seconds_until_auto_pause = lookup(var.configuration_rds.scaling_configuration, "seconds_until_auto_pause", 300)
    min_capacity             = lookup(var.configuration_rds.scaling_configuration, "min_capacity", 2)
    max_capacity             = lookup(var.configuration_rds.scaling_configuration, "max_capacity", 2)
    timeout_action           = lookup(var.configuration_rds.scaling_configuration, "timeout_action", "RollbackCapacityChange")
  }
}

resource "aws_ssm_parameter" "secret_password" {
  name        = "/${var.stack_id}/${lookup(var.configuration_rds, "rds_name")}/DB_PASSWORD"
  type        = "SecureString"
  value       = random_password.password.result

  tags = {
    environment = var.stack_id
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_user" {
  name        = "/${var.stack_id}/${lookup(var.configuration_rds, "rds_name")}/DB_USERNAME"
  type        = "SecureString"
  value       = lookup(var.configuration_rds, "master_username")

  tags = {
    environment = var.stack_id
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_database" {
  name        = "/${var.stack_id}/${lookup(var.configuration_rds, "rds_name")}/DB_DATABASE"
  type        = "SecureString"
  value       = lookup(var.configuration_rds, "database_name")

  tags = {
    environment = var.stack_id
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_port" {
  name        = "/${var.stack_id}/${lookup(var.configuration_rds, "rds_name")}/DB_PORT"
  type        = "SecureString"
  value       = aws_rds_cluster.db.port

  tags = {
    environment = var.stack_id
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_host" {
  name        = "/${var.stack_id}/${lookup(var.configuration_rds, "rds_name")}/DB_HOST"
  type        = "SecureString"
  value       = aws_rds_cluster.db.endpoint

  tags = {
    environment = var.stack_id
    Source = "Terraform"
  }
}
