variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "stack_id" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "vpc_id" {
  description = "ID VPC use security groups"
  type        = string
}

variable "subnets" {
  description = "Array subnets to associate"
  type        = list(string)
}

variable "kms_key_id" {
  description = "Use KMS custom"
  type        = string
  default     = null
  nullable    = true
}

variable "ingress" {
  description = "ingress"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      protocol    = "tcp"
      from_port   = 6379
      to_port     = 6379
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol    = "tcp"
      from_port   = 6380
      to_port     = 6380
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "egress" {
  description = "egress"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}


variable "configuration_elasticache" {
  description = "Parameter configuration creation elasticache"
  type = object({
    name                     = string
    engine                   = string
    daily_snapshot_time      = optional(string, null)
    snapshot_retention_limit = optional(number, 1)
    major_engine_version     = optional(string, "7")

    cache_usage_limits = optional(object({
      data_storage = object({
        maximum = number
        unit    = string
      })
      ecpu_per_second = object({
        maximum = number
      })
    }), null)
  })
}

variable "tags" {
  description = "A map of tags to assign to the repository"
  type        = map(string)
  default     = {}
}
