variable "project" {
  description = "A unique identifier for the deployment"
  type        = string
}

variable "environment" {
  description = "A unique identifier for the environment"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se crearán los endpoints"
  type        = string
}

variable "route_table_ids" {
  description = "Lista de IDs de las tablas de ruteo que deben asociarse al endpoint"
  type        = list(string)
}

variable "endpoints" {
  description = "Mapa de servicios a habilitar (s3, dynamodb)"
  type        = set(string)
  default     = ["s3", "dynamodb"]
}

variable "tags" {
  description = "Tags adicionales para los recursos"
  type        = map(string)
  default     = {}
}