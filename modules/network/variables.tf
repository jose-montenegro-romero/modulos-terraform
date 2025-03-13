variable "stack_id" {
  description = "Nombre del ambiente"
  type        = string
}

variable "layer" {
  description = "Nombre del proyecto"
  type        = string
}

variable "vpc_cidr" {
  description = "Identifier CIDR VPC"
  type        = string
}

variable "subnets_private" {
  description = "List subnet private"
  type        = list(any)
}
variable "subnets_public" {
  description = "List subnet public"
  type        = list(any)
}
