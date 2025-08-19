variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "stack_id" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "vpc" {
  description = "ID VPC use security groups"
  type        = string
}

variable "db_subnets" {
  description = "Array subnets associate"
  type        = list(string)
}

variable "configuration_efs" {
  description = "Parameter configuration-creation EFS"
  type        = any
}
