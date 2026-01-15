resource "aws_security_group" "sg_db" {
  name        = "rds-sg-${lookup(var.configuration_rds, "rds_name")}-${var.project}-${var.environment}"
  vpc_id      = var.vpc
  description = "Enable access to the RDS DB ${lookup(var.configuration_rds, "rds_name")} ${var.project} ${var.environment}"

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
    Name        = "rds-sg-${lookup(var.configuration_rds, "rds_name")}-${var.project}-${var.environment}"
    Environment = var.environment
    Source      = "Terraform"
  }
}

resource "aws_db_subnet_group" "default_subnet_rds" {
  name        = "subnet-rds-${lookup(var.configuration_rds, "rds_name")}-${var.project}-${var.environment}"
  description = replace("subnet-rds-${lookup(var.configuration_rds, "rds_name")}-${var.project}-${var.environment}", "/[-_]/", " ")
  subnet_ids  = var.db_subnets_private

  tags = {
    Name        = "DB-SG-${lookup(var.configuration_rds, "rds_name")}_${var.project}_${var.environment}"
    Environment = var.environment
    Source      = "Terraform"
  }
}

resource "aws_rds_cluster_parameter_group" "rds_cluster_parameter_group" {
  name        = replace("parameter-group-${lookup(var.configuration_rds, "rds_name")}-${var.project}-${var.environment}", "_", "-")
  family      = lookup(var.configuration_rds, "family", "aurora-mysql8.0")
  description = "Cluster parameter group ${lookup(var.configuration_rds, "rds_name")} ${var.project} ${var.environment}"

  dynamic "parameter" {
    for_each = length(coalesce(lookup(var.configuration_rds, "parameters", []), [])) == 0 ? [] : lookup(var.configuration_rds, "parameters")

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "#%&*()-_=+[]{}<>:?"
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier              = replace("${lookup(var.configuration_rds, "rds_name")}-${var.project}-${var.environment}", "_", "-")
  availability_zones              = lookup(var.configuration_rds, "availability_zones", null)
  engine                          = lookup(var.configuration_rds, "engine", "aurora-mysql")
  engine_mode                     = lookup(var.configuration_rds, "engine_mode", null)
  engine_version                  = lookup(var.configuration_rds, "engine_version", null)
  database_name                   = lookup(var.configuration_rds, "database_name")
  master_username                 = lookup(var.configuration_rds, "master_username")
  master_password                 = lookup(var.configuration_rds, "manage_master_user_password", true) == true ? null : random_password.password.result
  manage_master_user_password     = lookup(var.configuration_rds, "manage_master_user_password", true)
  port                            = lookup(var.configuration_rds, "port", "3306")
  vpc_security_group_ids          = ["${aws_security_group.sg_db.id}"]
  db_subnet_group_name            = aws_db_subnet_group.default_subnet_rds.name
  backup_retention_period         = lookup(var.configuration_rds, "backup_retention_period", 7)
  preferred_backup_window         = lookup(var.configuration_rds, "preferred_backup_window", "23:00-00:00")
  deletion_protection             = lookup(var.configuration_rds, "deletion_protection", true)
  allow_major_version_upgrade     = lookup(var.configuration_rds, "allow_major_version_upgrade", null)
  storage_encrypted               = lookup(var.configuration_rds, "storage_encrypted", false)
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.rds_cluster_parameter_group.name

  dynamic "scaling_configuration" {
    for_each = var.configuration_rds.scaling_configuration != null ? [var.configuration_rds.scaling_configuration] : []
    content {
      auto_pause               = lookup(scaling_configuration.value, "auto_pause", true)
      seconds_until_auto_pause = lookup(scaling_configuration.value, "seconds_until_auto_pause", 300)
      min_capacity             = lookup(scaling_configuration.value, "min_capacity", 2)
      max_capacity             = lookup(scaling_configuration.value, "max_capacity", 2)
      timeout_action           = lookup(scaling_configuration.value, "timeout_action", "RollbackCapacityChange")
    }
  }

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.configuration_rds.serverlessv2_scaling_configuration != null ? [var.configuration_rds.serverlessv2_scaling_configuration] : []
    content {
      max_capacity = lookup(var.configuration_rds.serverlessv2_scaling_configuration, "max_capacity", 1.0)
      min_capacity = lookup(var.configuration_rds.serverlessv2_scaling_configuration, "min_capacity", 0.5)
    }

  }

  tags = merge(var.tags, {
    Name        = replace("${lookup(var.configuration_rds, "rds_name")}-${var.project}-${var.environment}", "_", "-")
    Environment = var.environment
    Source      = "Terraform"
  })
}

resource "aws_rds_cluster_instance" "rds_cluster_instance" {
  identifier          = replace("${lookup(var.configuration_rds, "rds_name")}-${var.project}-${var.environment}-instance", "_", "-")
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

  tags = merge(var.tags, {
    Name        = replace("${lookup(var.configuration_rds, "rds_name")}-${var.project}-${var.environment}-instance", "_", "-")
    Environment = var.environment
    Source      = "Terraform"
  })
}

resource "aws_rds_cluster_instance" "rds_cluster_instance_reader" {

  count = length(lookup(var.configuration_rds, "multi_az", [])) != 0 ? length(lookup(var.configuration_rds, "multi_az")) : 0

  identifier          = replace("${lookup(var.configuration_rds, "rds_name")}-${var.project}-${var.environment}-instance-${count.index + 1}", "_", "-")
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

  tags = merge(var.tags, {
    Name        = replace("${lookup(var.configuration_rds, "rds_name")}-${var.project}-${var.environment}-instance-${count.index + 1}", "_", "-")
    Environment = var.environment
    Source      = "Terraform"
  })
}

// IAM Role + Policy attach for Enhanced Monitoring
data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "iam_role" {
  name_prefix        = replace(substr(replace("role-${lookup(var.configuration_rds, "rds_name")}-${var.project}-${var.environment}", "_", "-"), 0, 38), "/-$/", "")
  assume_role_policy = data.aws_iam_policy_document.iam_policy_document.json
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_ssm_parameter" "secret_password" {
  count = lookup(var.configuration_rds, "manage_master_user_password", true) == true ? 1 : 0

  name  = "/${var.environment}/${lookup(var.configuration_rds, "rds_name")}/DB_PASSWORD"
  type  = "SecureString"
  value = random_password.password.result

  tags = {
    Environment = var.environment
    Source      = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_user" {
  name  = "/${var.environment}/${lookup(var.configuration_rds, "rds_name")}/DB_USERNAME"
  type  = "SecureString"
  value = lookup(var.configuration_rds, "master_username")

  tags = {
    Environment = var.environment
    Source      = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_database" {
  name  = "/${var.environment}/${lookup(var.configuration_rds, "rds_name")}/DB_DATABASE"
  type  = "SecureString"
  value = lookup(var.configuration_rds, "database_name")

  tags = {
    Environment = var.environment
    Source      = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_port" {
  name  = "/${var.environment}/${lookup(var.configuration_rds, "rds_name")}/DB_PORT"
  type  = "SecureString"
  value = aws_rds_cluster.rds_cluster.port

  tags = {
    Environment = var.environment
    Source      = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_host" {
  name  = "/${var.environment}/${lookup(var.configuration_rds, "rds_name")}/DB_HOST"
  type  = "SecureString"
  value = aws_rds_cluster.rds_cluster.endpoint

  tags = {
    Environment = var.environment
    Source      = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_host_reader" {
  name  = "/${var.environment}/${lookup(var.configuration_rds, "rds_name")}/DB_HOST_READER"
  type  = "SecureString"
  value = aws_rds_cluster.rds_cluster.reader_endpoint

  tags = {
    Environment = var.environment
    Source      = "Terraform"
  }
}
