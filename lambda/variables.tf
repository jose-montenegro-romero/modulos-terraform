variable "stack_id" {
  description = "Nombre del ambiente"
  type        = string
}

variable "layer" {
  description = "Nombre del proyecto"
  type        = string
}

variable "subnets" {
  description = "Array subnets to associate"
  type        = list(string)
  default     = []
}

variable "configuration_lambda" {
  description = "Configuración para la lambda"
  type = object({
    name        = string
    handler     = string
    runtime     = string
    source_dir  = string
    variables   = optional(map(string), {})
    timeout     = optional(number, null)
    memory_size = optional(number, null)
  })
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
