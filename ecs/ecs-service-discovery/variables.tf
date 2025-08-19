variable "stack_id" {
  description = "A unique identifier for the environment"
  type        = string
}

variable "vpc_id" {
  description = "ID VPC"
  type        = string
}

variable "namespace_name" {
  description = "Nombre para el namespace de ecs"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}