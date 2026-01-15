variable "project" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "certificate_arn" {
  description = "ARN certificate manager"
  type        = string
  default     = null
}

variable "web_acl_id" {
  description = "WAF ACL rule id"
  type        = string
  default     = null
}

variable "configuration_cloudfront" {
  description = "Parameter configuration creation cloudfront"
  type        = any
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
