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

variable "subnets_private_db" {
  description = "List subnet private DB"
  type        = list(any)
  default     = []
}

variable "subnets_public" {
  description = "List subnet public"
  type        = list(any)
}

variable "transit_gateway_id" {
  description = "TGW ID compartido desde otra cuenta"
  type        = string
  default     = null
  nullable    = true
}

variable "routes_private" {
  description = "A list of private routes to add to the route table."
  type = list(object({
    cidr_block      = string
    nat_gateway     = optional(bool, false)
    transit_gateway = optional(bool, false)
  }))
  default = []
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
