resource "aws_security_group" "sg_db" {
  name        = "sgDb_${lookup(var.configuration_rds, "rds_name")}_${var.layer}_${var.stack_id}"
  vpc_id      = var.vpc
  description = "Enable access to the RDS DB"

  dynamic "ingress" {

    for_each = lookup(var.configuration_rds, "ingress")

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {

    for_each = lookup(var.configuration_rds, "egress")

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
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

resource "aws_rds_cluster_parameter_group" "rds_cluster_parameter_group" {
  name        = replace("parameter-group-${lookup(var.configuration_rds, "rds_name")}-${var.layer}-${var.stack_id}", "_", "-")
  family      = lookup(var.configuration_rds, "family", "aurora-mysql8.0")
  description = "Cluster parameter group ${lookup(var.configuration_rds, "rds_name")} ${var.layer} ${var.stack_id}"

  dynamic "parameter" {
    for_each = lookup(var.configuration_rds, "parameters", [])
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "#%&*()-_=+[]{}<>:?"
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier              = replace("${lookup(var.configuration_rds, "rds_name")}-${var.layer}-${var.stack_id}", "_", "-")
  engine                          = lookup(var.configuration_rds, "engine", "aurora-mysql")
  engine_mode                     = lookup(var.configuration_rds, "engine_mode", null)
  engine_version                  = lookup(var.configuration_rds, "engine_version", null)
  database_name                   = lookup(var.configuration_rds, "database_name")
  master_username                 = lookup(var.configuration_rds, "master_username")
  master_password                 = random_password.password.result
  port                            = lookup(var.configuration_rds, "port", "3306")
  vpc_security_group_ids          = ["${aws_security_group.sg_db.id}"]
  db_subnet_group_name            = aws_db_subnet_group.default_subnet_rds.name
  backup_retention_period         = lookup(var.configuration_rds, "backup_retention_period", 7)
  preferred_backup_window         = lookup(var.configuration_rds, "preferred_backup_window", "23:00-00:00")
  deletion_protection             = lookup(var.configuration_rds, "deletion_protection", true)
  allow_major_version_upgrade     = lookup(var.configuration_rds, "allow_major_version_upgrade", null)
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.rds_cluster_parameter_group.name

  serverlessv2_scaling_configuration {
    max_capacity = lookup(var.configuration_rds.serverlessv2_scaling_configuration, "max_capacity", 1.0)
    min_capacity = lookup(var.configuration_rds.serverlessv2_scaling_configuration, "min_capacity", 0.5)
  }
}

resource "aws_rds_cluster_instance" "rds_cluster_instance" {
  identifier          = replace("${lookup(var.configuration_rds, "rds_name")}-${var.layer}-${var.stack_id}-instance", "_", "-")
  cluster_identifier  = aws_rds_cluster.rds_cluster.id
  instance_class      = lookup(var.configuration_rds, "instance_class", "db.serverless")
  publicly_accessible = lookup(var.configuration_rds, "publicly_accessible", null)
  engine              = aws_rds_cluster.rds_cluster.engine
  engine_version      = aws_rds_cluster.rds_cluster.engine_version

  promotion_tier                        = lookup(var.configuration_rds, "promotion_tier", null)
  auto_minor_version_upgrade            = lookup(var.configuration_rds, "auto_minor_version_upgrade", null)
  performance_insights_enabled          = lookup(var.configuration_rds, "performance_insights_enabled", null)
  performance_insights_retention_period = lookup(var.configuration_rds, "performance_insights_retention_period", null)
  monitoring_interval                   = lookup(var.configuration_rds, "monitoring_interval", null)
  monitoring_role_arn                   = lookup(var.configuration_rds, "monitoring_interval", 0) > 0 ? aws_iam_role.iam_role.arn : null
}

resource "aws_rds_cluster_instance" "rds_cluster_instance_reader" {

  count = length(lookup(var.configuration_rds, "multi_az", [])) != 0 ? length(lookup(var.configuration_rds, "multi_az")) : 0

  identifier          = replace("${lookup(var.configuration_rds, "rds_name")}-${var.layer}-${var.stack_id}-instance-${count.index + 1}", "_", "-")
  cluster_identifier  = aws_rds_cluster.rds_cluster.id
  instance_class      = lookup(var.configuration_rds.multi_az[count.index], "instance_class", "db.serverless")
  publicly_accessible = lookup(var.configuration_rds.multi_az[count.index], "publicly_accessible", null)
  engine              = aws_rds_cluster.rds_cluster.engine
  engine_version      = aws_rds_cluster.rds_cluster.engine_version

  promotion_tier                        = lookup(var.configuration_rds.multi_az[count.index], "promotion_tier", null)
  auto_minor_version_upgrade            = lookup(var.configuration_rds.multi_az[count.index], "auto_minor_version_upgrade", null)
  performance_insights_enabled          = lookup(var.configuration_rds.multi_az[count.index], "performance_insights_enabled", null)
  performance_insights_retention_period = lookup(var.configuration_rds.multi_az[count.index], "performance_insights_retention_period", null)
  monitoring_interval                   = lookup(var.configuration_rds.multi_az[count.index], "monitoring_interval", null)
  monitoring_role_arn                   = lookup(var.configuration_rds.multi_az[count.index], "monitoring_interval", 0) > 0 ? aws_iam_role.iam_role.arn : null
}

// IAM Role + Policy attach for Enhanced Monitoring
data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_role" {
  name_prefix        = replace("role-${lookup(var.configuration_rds, "rds_name")}-${var.layer}-${var.stack_id}", "_", "-")
  assume_role_policy = data.aws_iam_policy_document.iam_policy_document.json
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_ssm_parameter" "secret_password" {
  name  = "/${var.stack_id}/${lookup(var.configuration_rds, "rds_name")}/DB_PASSWORD"
  type  = "SecureString"
  value = random_password.password.result

  tags = {
    environment = var.stack_id
    Source      = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_user" {
  name  = "/${var.stack_id}/${lookup(var.configuration_rds, "rds_name")}/DB_USERNAME"
  type  = "SecureString"
  value = lookup(var.configuration_rds, "master_username")

  tags = {
    environment = var.stack_id
    Source      = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_database" {
  name  = "/${var.stack_id}/${lookup(var.configuration_rds, "rds_name")}/DB_DATABASE"
  type  = "SecureString"
  value = lookup(var.configuration_rds, "database_name")

  tags = {
    environment = var.stack_id
    Source      = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_port" {
  name  = "/${var.stack_id}/${lookup(var.configuration_rds, "rds_name")}/DB_PORT"
  type  = "SecureString"
  value = aws_rds_cluster.rds_cluster.port

  tags = {
    environment = var.stack_id
    Source      = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_host" {
  name  = "/${var.stack_id}/${lookup(var.configuration_rds, "rds_name")}/DB_HOST"
  type  = "SecureString"
  value = aws_rds_cluster.rds_cluster.endpoint

  tags = {
    environment = var.stack_id
    Source      = "Terraform"
  }
}
