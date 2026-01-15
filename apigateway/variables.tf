variable "project" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "configuration_apigateway" {
  description = "Parameter configuration creation apigateway"
  type = object({
    name               = string
    enable_vpc_link    = optional(bool, false)
    vpc_link_nlb_arn   = optional(string, null)
    binary_media_types = optional(list(string), null)
  })
}

///////////////////////////////////////////////////////////////////////
/////////////// Create Api Key ////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
variable "api_key_config" {
  description = "Configuración completa de API Key y Usage Plan"
  type = object({
    enabled = bool
    usage_plan = optional(object({
      throttle = optional(object({
        rate_limit  = number
        burst_limit = number
        }), {
        rate_limit  = 10
        burst_limit = 2
      })
      quota = optional(object({
        limit  = number
        period = string
        }), {
        limit  = 1000
        period = "MONTH"
      })
    }))
  })
  default = {
    enabled = false
  }
}



variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
