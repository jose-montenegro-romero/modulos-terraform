output "network_interface_ids" {
  value = aws_vpc_endpoint.vpc_endpoint.network_interface_ids
}

output "target_group_arn" {
  value = aws_lb_target_group.s3_target_group.arn
}