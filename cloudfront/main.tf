resource "aws_cloudfront_distribution" "cloudfront_distribution" {

  comment             = replace("${lookup(var.configuration_cloudfront, "cloudfront_name")} ${var.layer} ${var.stack_id}", "/[-_]/", " ")
  enabled             = lookup(var.configuration_cloudfront, "enabled", true)
  is_ipv6_enabled     = lookup(var.configuration_cloudfront, "is_ipv6_enabled", false)
  default_root_object = lookup(var.configuration_cloudfront, "default_root_object", null)
  price_class         = lookup(var.configuration_cloudfront, "price_class", null)

  aliases = var.certificate_arn != null ? lookup(var.configuration_cloudfront, "aliases") : []

  web_acl_id = var.web_acl_id
  #   wait_for_deployment = false

  dynamic "origin" {
    for_each = lookup(var.configuration_cloudfront, "origins")
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = lookup(origin.value, "origin_path", null)

      origin_access_control_id = lookup(origin.value, "origin_access_control_id", null)

      dynamic "custom_origin_config" {
        for_each = lookup(origin.value, "custom_origin_config", null) != null ? [0] : []
        content {
          http_port                = lookup(origin.value.custom_origin_config, "http_port", 80)
          https_port               = lookup(origin.value.custom_origin_config, "https_port", 443)
          origin_protocol_policy   = lookup(origin.value.custom_origin_config, "origin_protocol_policy", "http-only")
          origin_ssl_protocols     = lookup(origin.value.custom_origin_config, "origin_ssl_protocols", ["TLSv1", "TLSv1.1", "TLSv1.2"])
          origin_keepalive_timeout = lookup(origin.value.custom_origin_config, "origin_keepalive_timeout", 60)
          origin_read_timeout      = lookup(origin.value.custom_origin_config, "origin_read_timeout", 60)
        }
      }
      dynamic "custom_header" {
        for_each = lookup(origin.value, "custom_headers", [])
        content {
          name  = custom_header.value["name"]
          value = custom_header.value["value"]
        }
      }
      dynamic "s3_origin_config" {
        for_each = lookup(origin.value, "s3_origin_config", null) != null ? [0] : []
        content {
          origin_access_identity = lookup(origin.value.s3_origin_config, "origin_access_identity")
        }
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.certificate_arn
    ssl_support_method             = var.certificate_arn != null ? lookup(var.configuration_cloudfront, "ssl_support_method", "sni-only") : null
    minimum_protocol_version       = var.certificate_arn != null ? lookup(var.configuration_cloudfront, "minimum_protocol_version", "TLSv1.2_2021") : null
    cloudfront_default_certificate = var.certificate_arn != null ? false : true
  }

  dynamic "default_cache_behavior" {
    for_each = lookup(var.configuration_cloudfront, "default_cache_behavior", [])
    content {
      viewer_protocol_policy = lookup(default_cache_behavior.value, "viewer_protocol_policy", "redirect-to-https")
      allowed_methods        = lookup(default_cache_behavior.value, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
      cached_methods         = lookup(default_cache_behavior.value, "cached_methods", ["GET", "HEAD", "OPTIONS"])
      target_origin_id       = default_cache_behavior.value.target_origin_id
      /* connection_timeout     = lookup(default_cache_behavior.value, "connection_timeout", 10)
      connection_attempts    = lookup(default_cache_behavior.value, "connection_attempts", 3) */

      forwarded_values {
        query_string = lookup(default_cache_behavior.value, "query_string", false)
        headers      = lookup(default_cache_behavior.value, "headers", null)

        cookies {
          forward           = lookup(default_cache_behavior.value, "cookies_forward", "none")
          whitelisted_names = lookup(default_cache_behavior.value, "cookies_whitelisted_names", null)
        }
      }

      compress    = lookup(default_cache_behavior.value, "compress", true)
      min_ttl     = lookup(default_cache_behavior.value, "min_ttl", 0)
      default_ttl = lookup(default_cache_behavior.value, "default_ttl", 0)
      max_ttl     = lookup(default_cache_behavior.value, "max_ttl", 0)
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = lookup(var.configuration_cloudfront, "ordered_cache_behavior", [])

    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      viewer_protocol_policy = lookup(ordered_cache_behavior.value, "viewer_protocol_policy", "redirect-to-https")
      allowed_methods        = lookup(ordered_cache_behavior.value, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
      cached_methods         = lookup(ordered_cache_behavior.value, "cached_methods", ["GET", "HEAD", "OPTIONS"])
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      trusted_signers        = lookup(ordered_cache_behavior.value, "trusted_signers", null)
      /* connection_timeout     = lookup(ordered_cache_behavior.value, "connection_timeout", 10)
      connection_attempts    = lookup(ordered_cache_behavior.value, "connection_attempts", 3) */

      forwarded_values {
        query_string = lookup(ordered_cache_behavior.value, "query_string", false)
        headers      = try(ordered_cache_behavior.value.forward_values_headers, null)

        cookies {
          forward           = lookup(ordered_cache_behavior.value, "cookies_forward", "none")
          whitelisted_names = lookup(ordered_cache_behavior.value, "cookies_whitelisted_names", null)
        }
      }

      compress    = lookup(ordered_cache_behavior.value, "compress", true)
      min_ttl     = lookup(ordered_cache_behavior.value, "min_ttl", 0)
      default_ttl = lookup(ordered_cache_behavior.value, "default_ttl", 0)
      max_ttl     = lookup(ordered_cache_behavior.value, "max_ttl", 0)

      dynamic "lambda_function_association" {
        for_each = lookup(ordered_cache_behavior.value, "lambda_function_association", null) == null ? [] : [true]
        content {
          event_type   = lookup(ordered_cache_behavior.value.lambda_function_association, "event_type", null)
          include_body = lookup(ordered_cache_behavior.value.lambda_function_association, "include_body", null)
          lambda_arn   = lookup(ordered_cache_behavior.value.lambda_function_association, "lambda_arn", null)
        }
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = length(lookup(var.configuration_cloudfront, "custom_error_response", [])) != 0 ? lookup(var.configuration_cloudfront, "custom_error_response") : []
    content {
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
      error_code            = custom_error_response.value.error_code
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = lookup(var.configuration_cloudfront, "restriction_type", "none")
      locations        = lookup(var.configuration_cloudfront, "locations", [])
    }
  }

  tags = merge(var.tags, {
    Name        = "${lookup(var.configuration_cloudfront, "cloudfront_name", )}_${var.layer}_${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}
