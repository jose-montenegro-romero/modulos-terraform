variable "stack_id" {
  description = "Nombre del ambiente"
  type        = string
}

variable "layer" {
  description = "Nombre del proyecto"
  type        = string
}

variable "name" {
  description = "Nombre del security group"
  type        = string
}


variable "vpc_id" {
  description = "Identifier VPC"
  type        = string
}

variable "ingress" {
  description = "ingress"
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), null)
    security_groups = optional(list(string), null)
  }))
  default = []
}

variable "egress" {
  description = "egress"
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), null)
    security_groups = optional(list(string), null)
  }))
  default = []
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
