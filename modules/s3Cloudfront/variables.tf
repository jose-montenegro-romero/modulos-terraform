variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "stack_id" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "certificate_arn" {
  description = "ARN certificate manager"
  type        = string
  default     = null
}

variable "configuration_s3" {
  description = "Parameter configuration creation s3"
  type        = any
}