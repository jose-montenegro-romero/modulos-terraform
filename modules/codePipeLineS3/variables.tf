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

variable "vpc" {
  description = "ID VPC use security groups"
  type        = string
}

variable "repository_name" {
  description = "Name repository"
  type        = string
}

variable "repository_branch_names" {
  description = "Name branch for repository"
  type        = string
}

variable "BucketName" {
  description = "Name bucket for application"
  type        = string
}

variable "CacheControl" {
  description = "CacheControl bucket for application"
  type        = string
  default     = null
}

variable "ConnectionArn" {
  description = "ARN github connection"
  type        = string
}

variable "environment_variable" {
  description = "Array Environment variables codeBuild"
  type        = any
  default     = []
}

variable "cloudfront_id" {
  description = "ID Cloudfront"
  type        = string
  default     = ""
}

variable "compute_type" {
  description = "Type compute type for codebuild"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "enabled_clear_cache" {
  description = "Value for enabled stage clear cache"
  type        = bool
  default     = false
}

variable "buildspec_cache_clear" {
  description = "Value for enabled stage test"
  type        = string
  default     = null
}