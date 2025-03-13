
variable "name"               { }
variable "tags"               { default = {}}
variable "addresses"          { default = [] } 
variable "description"        { default = ""}
variable "ip_address_version" { default = "IPV4" }
variable "scope"              { default = "REGIONAL"}