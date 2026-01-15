variable "project" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "configuration_acm" {
  description = "Parameter configuration creation ACM"
  type = object({
    domain            = string
    private_key       = string
    certificate_body  = string
    certificate_chain = optional(string, null)
  })
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
