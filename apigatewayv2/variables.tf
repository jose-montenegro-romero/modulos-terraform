variable "project" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "vpc_id" {
  description = "ID VPC use security groups"
  type        = string
}

variable "subnets" {
  description = "Array subnets to associate"
  type        = list(string)
  default     = []
}

variable "configuration_apigateway" {
  description = "Parameter configuration creation apigateway"
  type = object({
    name                         = string
    protocol_type                = optional(string, "HTTP")
    route_selection_expression   = optional(string, null)
    ip_address_type              = optional(string, null)
    disable_execute_api_endpoint = optional(bool, null)
    enable_vpc_link              = optional(bool, false)

    cors_configuration = optional(
      object({
        allow_origins     = optional(list(string))
        allow_methods     = optional(list(string))
        allow_headers     = optional(list(string))
        expose_headers    = optional(list(string))
        max_age           = optional(number)
        allow_credentials = optional(bool)
    }), null)

    ingress = optional(
      list(
        object({
          from_port   = number
          to_port     = number
          protocol    = string
          cidr_blocks = list(string)
      })),
      [
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
    )

    egress = optional(
      list(
        object({
          from_port   = number
          to_port     = number
          protocol    = string
          cidr_blocks = list(string)
      })),
      [
        {
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    )

  })
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
