variable "wafv2_web_acl_arn" {
  type = string
}

variable "resources_arn" {
  type    = list(any)
  default = []
}
