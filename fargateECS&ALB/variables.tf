variable "project" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "region" {
  description = "Region where the infra is displayed"
  type        = string
}

variable "db_subnets_public" {
  description = "Array subnets publics to associate"
  type        = list(string)
}

variable "db_subnets_private" {
  description = "Array subnets publics to associate"
  type        = list(string)
}

variable "vpc" {
  description = "ID VPC use security groups"
  type        = string
}

variable "ecs_fargate" {
  description = "propiedades para desplegar fargate"
  type        = list(any)
}

variable "certificate_arn" {
  description = "ARN certificate manager"
  type        = string
  default     = null
}

variable "listener_rule_fargate" {
  description = "propiedades para desplegar fargate listener"
  type        = any
}

variable "extra_environments" {
  description = "variables extra para usar con el template ecs"
  type        = map(any)
}

variable "efs" {
  description = "variables configure filesystem"
  type        = map(any)
  default     = {}
}

