variable "project" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "vpc_id" {
  description = "ID VPC use security groups"
  type        = string
}

variable "lb_definition" {
  description = "definitions for lb"
  type        = any
}

variable "target_id" {
  description = "identify target"
  type        = string
}

variable "acm_certificate_arn" {
  description = "arn certificate"
  type        = string
  default     = null
}
