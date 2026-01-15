variable "name" {
  description = "Nombre para WAF"
  type        = string
}

variable "project" {
  description = "A unique identifier for the deployment"
  type        = string
}

variable "environment" {
  description = "A unique identifier for the environment"
  type        = string
}

variable "scope" {
  type    = string
  default = "CLOUDFRONT"
}

variable "allow_default_action" {
  type    = bool
  default = true
}

variable "visibility_config" {
  type        = map(string)
  description = "Visibility config for WAFv2 web acl. https://www.terraform.io/docs/providers/aws/r/wafv2_web_acl.html#visibility-configuration"
  default     = {}
}

variable "rules" {
  type    = list(any)
  default = []
}

variable "rules_ip_set" {
  type    = list(any)
  default = []
}

variable "rules_geo" {
  type    = list(any)
  default = []
}

variable "rules_rate" {
  type    = list(any)
  default = null
}

variable "rule_byte_match" {
  type    = list(any)
  default = []
}


variable "tags" {
  type    = map(any)
  default = {}
}
