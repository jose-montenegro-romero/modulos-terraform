variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "stack_id" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "configuration_route53_healthcheck" {
  description = "Parameter configuration creation health check"
  type        = any
}
