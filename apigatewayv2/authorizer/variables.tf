variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "stack_id" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "api_id" {
  description = "ID del apigateway a implementar rutas"
  type        = string
}

variable "execution_arn" {
  description = "ARN del apigateway"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "ARN de la lambda autorizadora"
  type        = string
}

variable "function_name" {
  description = "Nombre de la lambda autorizadora"
  type        = string
}


variable "configuration_authorizer" {
  description = "Parameter configuration creation custom domain apigateway"
  type = object({
    name                             = string
    authorizer_result_ttl_in_seconds = optional(number, 300)
    identity_sources                 = optional(list(string), ["$request.header.Authorization"])
    enable_simple_responses          = optional(bool, true)
  })
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
