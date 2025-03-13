variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "stack_id" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "instance_name" {
  description = "name instance for codedeploy"
  type        = string
}

variable "ConnectionArn" {
  description = "ARN github connection"
  type        = string
}

variable "repository_name" {
  description = "Name repository"
  type        = string
}

variable "repository_branch_names" {
  description = "Name branch for repository"
  type        = string
}