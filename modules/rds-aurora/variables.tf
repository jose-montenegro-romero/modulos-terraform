
variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "stack_id" {
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
  type        = any
}
