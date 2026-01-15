variable "project" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "api_id" {
  description = "ID del apigateway a implementar rutas"
  type        = string
}

variable "configuration_custom_domain" {
  description = "Parameter configuration creation custom domain apigateway"
  type = object({
    domain_name              = string
    regional_certificate_arn = string
    endpoint_type            = optional(string, "REGIONAL")
    security_policy          = optional(string, "TLS_1_2")
  })
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
