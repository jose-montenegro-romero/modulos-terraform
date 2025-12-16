variable "project" {
  description = "A unique identifier for the deployment"
  type        = string
}

variable "environment" {
  description = "A unique identifier for the environment"
  type        = string
}

variable "configuration_dynamodb" {
  description = "Configuration for the DynamoDB table"
  type = object({
    # Nombre de la tabla
    name           = string
    billing_mode = optional(string, "PAY_PER_REQUEST")
    # Claves principales
    hash_key       = string
    range_key      = optional(string) # Opcional, ya que no todas las tablas tienen range_key
    # Atributos: mapa de <Nombre_Atributo> = <Tipo_Atributo>
    attributes = map(string)
    # Índices Secundarios Globales (GSI)
    global_secondary_indexes = optional(map(object({
      hash_key           = string
      range_key          = optional(string)
      read_capacity      = number
      write_capacity     = number
      projection_type    = string
      non_key_attributes = optional(list(string))
    })), {})
    # Configuración de TTL (Opcional)
    ttl_attribute_name = optional(string)
    # Capacidad de lectura/escritura
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  })
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}