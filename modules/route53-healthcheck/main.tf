resource "aws_route53_health_check" "route53_health_check" {

  fqdn                            = lookup(var.configuration_route53_healthcheck, "fqdn", null)
  ip_address                      = lookup(var.configuration_route53_healthcheck, "ip_address", null)
  port                            = lookup(var.configuration_route53_healthcheck, "port", null)
  type                            = lookup(var.configuration_route53_healthcheck, "type", "HTTP")
  failure_threshold               = lookup(var.configuration_route53_healthcheck, "failure_threshold", "3")
  resource_path                   = lookup(var.configuration_route53_healthcheck, "resource_path", null)
  request_interval                = lookup(var.configuration_route53_healthcheck, "request_interval", "30")
  search_string                   = lookup(var.configuration_route53_healthcheck, "search_string", null)
  measure_latency                 = lookup(var.configuration_route53_healthcheck, "measure_latency", null)
  invert_healthcheck              = lookup(var.configuration_route53_healthcheck, "invert_healthcheck", null)
  disabled                        = lookup(var.configuration_route53_healthcheck, "disabled", null)
  enable_sni                      = lookup(var.configuration_route53_healthcheck, "enable_sni", null)
  child_healthchecks              = lookup(var.configuration_route53_healthcheck, "child_healthchecks", null)
  child_health_threshold          = lookup(var.configuration_route53_healthcheck, "child_health_threshold", null)
  cloudwatch_alarm_name           = lookup(var.configuration_route53_healthcheck, "cloudwatch_alarm_name", null)
  cloudwatch_alarm_region         = lookup(var.configuration_route53_healthcheck, "cloudwatch_alarm_region", null)
  insufficient_data_health_status = lookup(var.configuration_route53_healthcheck, "insufficient_data_health_status", null)
  regions                         = lookup(var.configuration_route53_healthcheck, "regions", null)
  routing_control_arn             = lookup(var.configuration_route53_healthcheck, "routing_control_arn", null)

  tags = {
    Name        = "${lookup(var.configuration_route53_healthcheck, "name")} ${var.layer} ${var.stack_id}"
    environment = var.stack_id
    source      = "Terraform"
  }
}

resource "aws_sns_topic" "sns_topic" {

  count = lookup(var.configuration_route53_healthcheck, "aws_sns_topic_subscription_endpoint", null) != null ? 1 : 0
  
  name     = replace("sns_topic_${lookup(var.configuration_route53_healthcheck, "name")}_${var.layer}_${var.stack_id}", " ", "_")

  #   provisioner "local-exec" {
  #     command = "aws sns subscribe --topic-arn ${self.arn} --region ${aws.virginia} --protocol email --notification-endpoint ${var.sns-subscribe-list}"
  #   }

  tags = {
    environment = var.stack_id
    source      = "Terraform"
  }
}

resource "aws_sns_topic_subscription" "sns_topic_subscription" {

  count = lookup(var.configuration_route53_healthcheck, "aws_sns_topic_subscription_endpoint", null) != null ? 1 : 0

  topic_arn = aws_sns_topic.sns_topic[0].arn
  protocol  = "email"
  endpoint  = lookup(var.configuration_route53_healthcheck, "aws_sns_topic_subscription_endpoint")
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_metric_alarm" {

  count = lookup(var.configuration_route53_healthcheck, "aws_sns_topic_subscription_endpoint", null) != null ? 1 : 0

  alarm_name          = replace("cloudwatch_metric_alarm_${lookup(var.configuration_route53_healthcheck, "name")}_${var.layer}_${var.stack_id}", " ", "_")
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"

  dimensions = {
    HealthCheckId = aws_route53_health_check.route53_health_check.id
  }

  alarm_description = "This metric monitors status of the health check ${lookup(var.configuration_route53_healthcheck, "name")} ${var.layer} ${var.stack_id}"
  alarm_actions     = [aws_sns_topic.sns_topic[0].arn]

  tags = {
    environment = var.stack_id
    source      = "Terraform"
  }
}
