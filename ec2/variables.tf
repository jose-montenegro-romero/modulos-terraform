variable "project" {
  description = "A unique identifier for the deployment"
  type        = string
}

variable "environment" {
  description = "A unique identifier for the environment"
  type        = string
}

variable "db_subnets_public" {
  description = "Array subnets to associate publics"
  type        = list(string)
}

variable "vpc" {
  description = "ID VPC use security groups"
  type        = string
}

variable "name" {
  description = "Name for EC2"
  type        = string
}

variable "ami" {
  description = "ID for AMI"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "disable_api_termination" {
  description = "disable_api_termination"
  type        = bool
  default     = true
}

variable "public_key" {
  description = "public_key"
  type        = string
  nullable    = false
}

variable "ingress" {
  description = "Define las reglas de entrada (ingress) para un grupo de seguridad."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress" {
  description = "Define las reglas de entrada (egress) para un grupo de seguridad."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "eip" {
  description = "Elastic IP"
  type        = bool
  default     = null
}

variable "template_file" {
  description = "Template script file"
  type        = string
  default     = null
}

variable "template_file_vars" {
  description = "Template script file vars"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}

variable "root_block_device" {
  description = "Configuración del volumen EBS raíz para la instancia EC2. Permite definir si se elimina al terminar, si está cifrado, el tamaño (en GiB) y el tipo de volumen."
  type = list(
    object({
      delete_on_termination = bool
      encrypted             = bool
      volume_size           = number
      volume_type           = string
    })
  )
  default = [
    {
      delete_on_termination = true
      encrypted = true
      volume_size = 8
      volume_type = "gp3"
    }
  ]
}

