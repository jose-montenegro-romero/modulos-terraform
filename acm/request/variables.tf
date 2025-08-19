variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "stack_id" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "configuration_acm" {
  description = "Parameter configuration creation ACM"
  type = object({
    domain_name               = string
    subject_alternative_names = optional(list(string), [])
    validation_method         = optional(string, "DNS")
  })
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
