locals {
  eni_list = tolist(var.network_interface_ids)
}

data "aws_network_interface" "s3_endpoint_eni" {
  count = var.count_interfaces
  id    = local.eni_list[count.index]
}

# Adjuntar las IPs del VPC Endpoint como targets al Target Group
resource "aws_lb_target_group_attachment" "s3_attachment" {
  count             = var.count_interfaces
  target_group_arn  = var.target_group_arn
  target_id         = data.aws_network_interface.s3_endpoint_eni[count.index].private_ip
  port              = 80
}
