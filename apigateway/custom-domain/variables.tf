variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "configuration_custom_domain" {
  description = "Parameter configuration creation custom domain apigateway"
  type = object({
    domain_name              = string
    regional_certificate_arn = string
    api_id                   = string
  })
}
