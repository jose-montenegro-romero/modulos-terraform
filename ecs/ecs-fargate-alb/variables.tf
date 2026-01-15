variable "project" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "region" {
  description = "Region where the infra is displayed"
  type        = string
}

variable "ingress" {
  description = "ingress"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "egress" {
  description = "egress"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "db_subnets_public" {
  description = "Array subnets publics to associate"
  type        = list(string)
}

variable "db_subnets_private" {
  description = "Array subnets publics to associate"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID VPC use security groups"
  type        = string
}

variable "ecs_cluster_reference" {
  description = "Referencia para cluster ecs."
  type = object({
    name = string
    id   = string
  })
}

variable "lb_id" {
  description = "ID para asociar lb"
  type        = string
}

variable "ecs_fargate" {
  description = "propiedades para desplegar fargate"
  type        = list(any)
}

variable "certificate_arn" {
  description = "ARN certificate manager"
  type        = string
  default     = null
}

variable "listener_rule_fargate" {
  description = "propiedades para desplegar fargate listener"
  type        = any
}

variable "efs" {
  description = "variables configure filesystem"
  type        = map(any)
  default     = {}
}

variable "cloudwatch_log_retention" {
  description = "Retención en días para los logs de cloudwatch"
  type        = number
  default     = 7
}

variable "tags" {
  description = "A map of tags to assign to the repository"
  type        = map(string)
  default     = {}
}
