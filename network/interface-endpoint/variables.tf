variable "project" {
  description = "A unique identifier for the deployment"
  type        = string
}

variable "environment" {
  description = "A unique identifier for the environment"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Subredes donde se crearán las interfaces del endpoint"
  type        = list(string)
}

variable "endpoints" {
  description = "Mapa de servicios. Ejemplo: { ec2 = \"ec2\", ssm = \"ssm\" }"
  type        = set(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR que puede comunicarse con los endpoints"
  type        = list(string)
  default     = ["10.0.0.0/16"] # Ajustar según tu VPC
}

variable "tags" {
  type    = map(string)
  default = {}
}