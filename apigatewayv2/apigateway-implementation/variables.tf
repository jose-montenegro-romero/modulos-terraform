variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "api_id" {
  description = "ID del apigateway a implementar rutas"
  type        = string
}

variable "api_stage_name" {
  description = "Nombre del stage."
  type        = string
  default     = "$default"
}


variable "routes" {
  description = "Lista de endpoints para crear en API Gateway"
  type = list(object({
    path               = string
    integration_method = string
    integration_type   = string
    integration_uri    = optional(string, null)
    vpc_link_enabled   = optional(bool, false)
    connection_id      = optional(string, null)
    api_key_required   = optional(bool, false)
    authorization_type = optional(string, "NONE")
    authorizer_id      = optional(string, null)

  }))
}
