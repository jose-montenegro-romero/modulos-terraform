variable "stack_id" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "layer" {
  description = "A unique identifier for the deployment. Used as a prefix for all the Openstack resources."
  type        = string
}

variable "configuration_codepipeline_terraform" {
  description = "Parameter configuration creation codepipeline terraform"
  type        = any
}

variable "ConnectionArn" {
  description = "ARN github connection"
  type        = string
}

