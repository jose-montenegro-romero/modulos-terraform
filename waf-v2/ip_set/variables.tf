
variable "name" {}

variable "project" {
  description = "A unique identifier for the deployment"
  type        = string
}

variable "environment" {
  description = "A unique identifier for the environment"
  type        = string
}

variable "tags" { default = {} }
variable "addresses" { default = [] }
variable "description" { default = "" }
variable "ip_address_version" { default = "IPV4" }
variable "scope" { default = "REGIONAL" }
