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

variable "acm_arn" {
  description = "ACM arn"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 webstatic arn"
  type        = string
}

variable "s3_bucket_id" {
  description = "S3 webstatic ID"
  type        = string
}

variable "configuration_pagestatic_private" {
  description = "Parameter configuration creation ACM"
  type = object({
    name                       = string
    enable_deletion_protection = optional(bool, true)
  })
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
