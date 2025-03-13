variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "stack_id" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "region" {
  description = "Region where the infra is displayed"
  type        = string
}

variable "db_subnets_private" {
  description = "Array subnets to associate publics"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Array security groups"
  type        = list(string)
}

variable "vpc" {
  description = "ID VPC use security groups"
  type        = string
}

variable "repository_name" {
  description = "Name repository"
  type        = string
}

variable "repository_url" {
  description = "URL repository for ecr"
  type        = string
}

variable "repository_branch_names" {
  description = "Name branch for repository"
  type        = string
}

variable "cluster_name" {
  description = "Name cluster ecs"
  type        = string
}

variable "service_name" {
  description = "Name service ecs"
  type        = string
}

variable "environment_variable" {
  description = "Array Environment variables codeBuild"
  type        = any
  default     = []
}

variable "container_name" {
  description = "Name container ecs"
  type        = string
}

variable "ConnectionArn" {
  description = "ARN github connection"
  type        = string
}

variable "enabled_automation" {
  description = "Value for enabled stage test"
  type        = bool
  default     = false
}
