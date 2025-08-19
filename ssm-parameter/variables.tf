variable "stack_id" {
  description = "Nombre del ambiente"
  type        = string
}

variable "layer" {
  description = "Nombre del proyecto"
  type        = string
}

variable "name" {
  description = "Nombre parameter store"
  type        = string
}

variable "type" {
  description = "Tipo de parameter store"
  type        = string
}

variable "value" {
  description = "Valor de parameter store"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}