variable "project" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "environment" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "name" {
  description = "Nombre para cluster ecs"
  type        = any
}

variable "tags" {
  description = "Tags"
  type        = map(any)
  default     = {}
}
