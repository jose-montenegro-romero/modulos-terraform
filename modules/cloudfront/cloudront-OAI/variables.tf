variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "stack_id" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "s3_reference" {
  description = "A unique identifier reference s3"
  type        = any
}

variable "configuration_cloudfront_oai" {
  description = "Parameter configuration creation cloudfront OAI"
  type        = any
}
