resource "aws_wafv2_web_acl_association" "wafv2_web_acl_association" {
  count = length(var.resources_arn) > 0 ? length(var.resources_arn) : 0

  web_acl_arn  = var.wafv2_web_acl_arn
  resource_arn = var.resources_arn[count.index]

}
