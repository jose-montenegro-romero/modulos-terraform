// Security groups
module "sg" {
  source = "../sg"


  project    = var.project
  environment = var.environment
  // configuration sg
  name    = "elasticache-${lookup(var.configuration_elasticache, "name")}"
  vpc_id  = var.vpc_id
  ingress = var.ingress
  egress  = var.egress
  // TAGS
  tags = var.tags
}

resource "aws_elasticache_serverless_cache" "elasticache_serverless_cache" {
  name        = replace("elasticache-${lookup(var.configuration_elasticache, "name")}-${var.project}-${var.environment}", "_", "-")
  description = replace("Elasticache ${lookup(var.configuration_elasticache, "name")} ${var.project} ${var.environment}", "/[-_]/", " ")
  engine      = lookup(var.configuration_elasticache, "engine")

  daily_snapshot_time      = lookup(var.configuration_elasticache, "daily_snapshot_time")
  kms_key_id               = var.kms_key_id
  major_engine_version     = lookup(var.configuration_elasticache, "major_engine_version")
  snapshot_retention_limit = lookup(var.configuration_elasticache, "snapshot_retention_limit")
  security_group_ids       = [module.sg.sg_reference.id]
  subnet_ids               = var.subnets

  dynamic "cache_usage_limits" {
    for_each = var.configuration_elasticache.cache_usage_limits != null ? [var.configuration_elasticache.cache_usage_limits] : []
    content {
      data_storage {
        maximum = cache_usage_limits.value.data_storage.maximum
        unit    = cache_usage_limits.value.data_storage.unit
      }
      ecpu_per_second {
        maximum = cache_usage_limits.value.ecpu_per_second.maximum
      }
    }
  }

  tags = merge(var.tags, {
    Name        = replace("elasticache-${lookup(var.configuration_elasticache, "name")}-${var.project}-${var.environment}", "_", "-")
    Environment = var.environment
    Source      = "Terraform"
  })
}
