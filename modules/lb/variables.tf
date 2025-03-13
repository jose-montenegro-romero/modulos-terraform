variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "stack_id" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "db_subnets_public" {
  description = "Array subnets to associate publics"
  type        = list(string)
}

variable "vpc" {
  description = "ID VPC use security groups"
  type        = string
}

variable "lb_definition" {
  description = "definitions for lb"
  type        = any
}

variable "acm_certificate_arn" {
  description = "arn certificate"
  type        = string
  default     = null
}

variable "target_id" {
  description = "identify target"
  type        = string
}
