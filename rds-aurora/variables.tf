
variable "project" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "db_subnets_private" {
  description = "Array subnets to associate publics"
  type        = list(string)
}

variable "vpc" {
  description = "ID VPC use security groups"
  type        = string
}

variable "configuration_rds" {
  description = "Parameter configuration creation rds aurora"
  type = object({
    ingress                 = any
    egress                  = any
    rds_name                = string
    database_name           = string
    master_username         = string
    availability_zones      = optional(list(string))
    engine_version          = string
    engine_mode             = string
    engine                  = string
    backup_retention_period = optional(number)
    deletion_protection     = optional(bool)
    port                    = optional(string)
    storage_encrypted       = optional(bool)

    instance_class = optional(string)

    family = string
    parameters = optional(
      list(
        object({
          name         = string
          value        = string
          apply_method = optional(string, null)
        })
      )
    )

    scaling_configuration = optional(
      object({
        auto_pause               = optional(bool)
        seconds_until_auto_pause = optional(number)
        min_capacity             = optional(number)
        max_capacity             = optional(number)
        timeout_action           = optional(string)
      })
    )

    serverlessv2_scaling_configuration = optional(
      object({
        max_capacity = number
        min_capacity = number
      })
    )

    multi_az = optional(
      list(
        object({
          instance_class                        = string
          promotion_tier                        = number
          auto_minor_version_upgrade            = bool
          performance_insights_enabled          = bool
          performance_insights_retention_period = number
          monitoring_interval                   = number
        })
    ), [])
  })
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
