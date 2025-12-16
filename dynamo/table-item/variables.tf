variable "project" {
  description = "A unique identifier for the deployment"
  type        = string
}

variable "environment" {
  description = "A unique identifier for the environment"
  type        = string
}

variable "table_name" {
  description = "Nombre de la tabla de DynamoDB"
  type        = string
}

variable "hash_key" {
  description = "Hash key de la tabla de DynamoDB"
  type        = string
}

variable "item" {
  description = "El contenido completo del elemento, proporcionado como una cadena JSON en formato DynamoDB (por ejemplo, {'AttributeName': {'S': 'Value'}})."
  type        = string
}

# example

# item = <<EOT
# {
#   "ID":       {"S": "clave-unica-123"},
#   "Nombre":   {"S": "Juan Perez"},
#   "Edad":     {"N": "35"},
#   "Activo":   {"BOOL": true},
#   "Etiquetas": {"SS": ["premium", "beta"]}
# }
# EOT