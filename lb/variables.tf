variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "stack_id" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "subnets" {
  description = "Array subnets to associate"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID VPC use security groups"
  type        = string
}

variable "configuration_lb" {
  description = "definitions for lb"
  type        = any
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
