#--------------------------------------------------------------
# Estos modulos crea los recursos necesarios para el WAF v2 Web ACL
#--------------------------------------------------------------
resource "aws_wafv2_web_acl" "wafv2_web_acl" {

  name        = replace("${var.name}-${var.layer}-${var.stack_id}", "_", "-")
  description = replace("${var.name} ${var.layer} ${var.stack_id}", "/[-_]/", " ")
  scope       = var.scope

  dynamic "custom_response_body" {
    for_each = var.allow_default_action ? [] : [1]
    content {
      key = "blocked_response_body"
      content = jsonencode({
        message = "Access Denied."
        code    = "WAF_BLOCKED"
      })
      content_type = "APPLICATION_JSON"
    }
  }


  default_action {
    dynamic "allow" {
      for_each = var.allow_default_action ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = var.allow_default_action ? [] : [1]
      content {
        custom_response {
          response_code            = 403                    
          custom_response_body_key = "blocked_response_body"
          response_header {
            name  = "Cache-Control"
            value = "no-store, no-cache"
          }
        }
      }
    }
  }

  dynamic "rule" {
    for_each = var.rules
    content {
      name     = lookup(rule.value, "name")
      priority = lookup(rule.value, "priority")

      override_action {
        dynamic "none" {
          for_each = length(lookup(rule.value, "override_action", {})) == 0 || lookup(rule.value, "override_action", {}) == "none" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = lookup(rule.value, "override_action", {}) == "count" ? [1] : []
          content {}
        }
      }

      statement {
        dynamic "managed_rule_group_statement" {
          for_each = length(lookup(rule.value, "managed_rule_group_statement", {})) == 0 ? [] : [lookup(rule.value, "managed_rule_group_statement", {})]
          content {
            name        = lookup(managed_rule_group_statement.value, "name")
            vendor_name = lookup(managed_rule_group_statement.value, "vendor_name", "AWS")
          }
        }
      }
      dynamic "visibility_config" {
        for_each = length(lookup(rule.value, "visibility_config")) == 0 ? [] : [lookup(rule.value, "visibility_config", {})]
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = lookup(visibility_config.value, "metric_name", "${var.name}-default-rule-metric-name")
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    }
  }

  dynamic "rule" {
    for_each = var.rules_ip_set
    content {
      name     = lookup(rule.value, "name")
      priority = lookup(rule.value, "priority")

      action {
        dynamic "allow" {
          for_each = length(lookup(rule.value, "action", {})) == 0 || lookup(rule.value, "action", {}) == "allow" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = lookup(rule.value, "action", {}) == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = lookup(rule.value, "action", {}) == "block" ? [1] : []
          content {}
        }
      }

      statement {
        dynamic "ip_set_reference_statement" {
          for_each = length(lookup(rule.value, "ip_set_reference_statement", {})) == 0 ? [] : [lookup(rule.value, "ip_set_reference_statement", {})]
          content {
            arn = lookup(ip_set_reference_statement.value, "arn")
            dynamic "ip_set_forwarded_ip_config" {
              for_each = length(lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", {})) == 0 ? [] : [lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", {})]
              content {
                fallback_behavior = lookup(ip_set_forwarded_ip_config.value, "fallback_behavior")
                header_name       = lookup(ip_set_forwarded_ip_config.value, "header_name")
                position          = lookup(ip_set_forwarded_ip_config.value, "position")
              }
            }
          }
        }
      }

      dynamic "visibility_config" {
        for_each = length(lookup(rule.value, "visibility_config")) == 0 ? [] : [lookup(rule.value, "visibility_config", {})]
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = lookup(visibility_config.value, "metric_name", "${var.name}-ip-rule-metric-name")
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    }
  }

  dynamic "rule" {
    for_each = var.rules_geo
    content {
      name     = lookup(rule.value, "name")
      priority = lookup(rule.value, "priority")

      action {
        dynamic "allow" {
          for_each = length(lookup(rule.value, "action", {})) == 0 || lookup(rule.value, "action", {}) == "allow" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = lookup(rule.value, "action", {}) == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = lookup(rule.value, "action", {}) == "block" ? [1] : []
          content {}
        }
      }

      statement {
        dynamic "geo_match_statement" {
          for_each = length(lookup(rule.value, "geo_match_statement", {})) == 0 ? [] : [lookup(rule.value, "geo_match_statement", {})]
          content {
            country_codes = lookup(geo_match_statement.value, "country_codes")
          }
        }
      }

      dynamic "visibility_config" {
        for_each = length(lookup(rule.value, "visibility_config")) == 0 ? [] : [lookup(rule.value, "visibility_config", {})]
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = lookup(visibility_config.value, "metric_name", "${var.name}-ip-rule-metric-name")
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    }
  }

  dynamic "rule" {
    for_each = var.rules_rate != null ? var.rules_rate : []
    content {
      name     = lookup(rule.value, "name")
      priority = lookup(rule.value, "priority")

      action {

        dynamic "allow" {
          for_each = length(lookup(rule.value, "action", {})) == 0 || lookup(rule.value, "action", {}) == "allow" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = lookup(rule.value, "action", {}) == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = length(lookup(rule.value, "action", {})) == 0 || lookup(rule.value, "action", {}) == "block" ? [1] : []
          content {}
        }
      }

      statement {
        dynamic "rate_based_statement" {
          for_each = length(lookup(rule.value, "rate_based_statement", {})) == 0 ? [] : [lookup(rule.value, "rate_based_statement", {})]
          content {
            limit              = lookup(rate_based_statement.value, "limit")
            aggregate_key_type = lookup(rate_based_statement.value, "aggregate_key_type", "IP")

            dynamic "forwarded_ip_config" {
              for_each = length(lookup(rate_based_statement.value, "forwarded_ip_config", {})) == 0 ? [] : [lookup(rate_based_statement.value, "forwarded_ip_config", {})]
              content {
                fallback_behavior = lookup(forwarded_ip_config.value, "fallback_behavior")
                header_name       = lookup(forwarded_ip_config.value, "header_name")
              }
            }
          }
        }
      }

      dynamic "visibility_config" {
        for_each = length(lookup(rule.value, "visibility_config")) == 0 ? [] : [lookup(rule.value, "visibility_config", {})]
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = lookup(visibility_config.value, "metric_name", "${var.name}-ip-rate-based-rule-metric-name")
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    }
  }

  dynamic "rule" {
    for_each = var.rule_byte_match
    content {
      name     = lookup(rule.value, "name")
      priority = lookup(rule.value, "priority")


      action {
        dynamic "count" {
          for_each = lookup(rule.value, "action", {}) == "count" ? [1] : []
          content {}
        }

        dynamic "allow" {
          for_each = length(lookup(rule.value, "action", {})) == 0 || lookup(rule.value, "action", {}) == "allow" ? [1] : []
          content {}
        }


        dynamic "block" {
          for_each = length(lookup(rule.value, "action", {})) == 0 || lookup(rule.value, "action", {}) == "block" ? [1] : []
          content {}
        }
      }

      statement {
        dynamic "byte_match_statement" {
          for_each = length(lookup(rule.value, "byte_match_statement", {})) == 0 ? [] : [lookup(rule.value, "byte_match_statement", {})]
          content {
            dynamic "field_to_match" {
              for_each = length(lookup(byte_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(byte_match_statement.value, "field_to_match", {})]
              content {
                dynamic "uri_path" {
                  for_each = length(lookup(field_to_match.value, "uri_path", {})) == 0 ? [] : [lookup(field_to_match.value, "uri_path")]
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = length(lookup(field_to_match.value, "all_query_arguments", {})) == 0 ? [] : [lookup(field_to_match.value, "all_query_arguments")]
                  content {}
                }
                dynamic "body" {
                  for_each = length(lookup(field_to_match.value, "body", {})) == 0 ? [] : [lookup(field_to_match.value, "body")]
                  content {}
                }
                dynamic "method" {
                  for_each = length(lookup(field_to_match.value, "method", {})) == 0 ? [] : [lookup(field_to_match.value, "method")]
                  content {}
                }
                dynamic "query_string" {
                  for_each = length(lookup(field_to_match.value, "query_string", {})) == 0 ? [] : [lookup(field_to_match.value, "query_string")]
                  content {}
                }
                dynamic "single_header" {
                  for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header")]
                  content {
                    name = lower(lookup(single_header.value, "name"))
                  }
                }
              }
            }
            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
            search_string         = lookup(byte_match_statement.value, "search_string")
            text_transformation {
              priority = lookup(byte_match_statement.value.text_transformation, "priority")
              type     = lookup(byte_match_statement.value.text_transformation, "type")
            }
          }
        }
      }


      dynamic "visibility_config" {
        for_each = length(lookup(rule.value, "visibility_config")) == 0 ? [] : [lookup(rule.value, "visibility_config", {})]
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = lookup(visibility_config.value, "metric_name", "${var.name}-ip-rate-based-rule-metric-name")
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    }
  }

  tags = merge(
    var.tags,
    { Name = var.name },
  )

  dynamic "visibility_config" {
    for_each = length(var.visibility_config) == 0 ? [] : [var.visibility_config]
    content {
      cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
      metric_name                = lookup(visibility_config.value, "metric_name", "${var.name}-default-web-acl-metric-name")
      sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
    }
  }
}
