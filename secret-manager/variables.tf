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

variable "value" {
  description = "Valor de parameter store"
  type        = string
  default     = ""
}

variable "random" {
  description = "Valor para crear valores random"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
