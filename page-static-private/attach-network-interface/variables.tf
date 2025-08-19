variable "network_interface_ids" {
  type = set(string)
}

variable "target_group_arn" {
  type = string
}

variable "count_interfaces" {
  type = number
}
