variable "name"                 { }
variable "tags"                 { }
variable "enabled"              { default = true }
variable "scope"                { default = "CLOUDFRONT" }
variable "allow_default_action" { default = true }
variable "visibility_config"    {
  type        = map(string)
  description = "Visibility config for WAFv2 web acl. https://www.terraform.io/docs/providers/aws/r/wafv2_web_acl.html#visibility-configuration"
  default     = {}
}
variable "rules"                { default = []   }
variable "rules_ip_set"         { default = []   }
variable "rules_geo"            { default = []   }
variable "rules_rate"           { default = null }
variable "resources_arn"        { default = []   }
variable "rule_byte_match"      { default = [] }
