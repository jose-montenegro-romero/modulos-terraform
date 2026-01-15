variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "api_gateway_rest_api_id" {
  description = "ID del apigateway a implementar rutas"
  type        = string
}

variable "api_gateway_rest_api_name" {
  description = "ID del apigateway a implementar rutas"
  type        = string
}

variable "api_gateway_rest_api_root_resource_id" {
  description = "ID de la ruta principal de apigateway"
  type        = string
}

variable "routes" {
  description = "Lista de endpoints para crear en API Gateway"
  type = list(object({
    path                    = string
    http_method             = string
    integration_type        = string
    authorization           = optional(string, null)
    authorizer_id           = optional(string, null)
    integration_uri         = optional(string, null)
    integration_http_method = optional(string, null)
    vpc_link_enabled        = optional(bool, false)
    connection_id           = optional(string, false)
    api_key_required        = optional(bool, false)

    request_parameters_method = optional(any, {})
    request_parameters        = optional(any, {})
    request_templates         = optional(any, {})
    response_parameters       = optional(any, {})

  }))
}
