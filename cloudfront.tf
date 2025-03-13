# Create cloudfront OAI Hermes
module "nha_cloudfront_oai_hermes" {
  source = "./modules/cloudfront/cloudront-OAI"

  layer                        = var.layer_2
  stack_id                     = var.stack_id
  configuration_cloudfront_oai = var.configuration_cloudfront_front_hermes_oai
  s3_reference                 = module.nha_s3_front_hermes.s3_reference
}

# Create cloudfront OAI Hermes
module "nha_cloudfront_oai_advantage" {
  source = "./modules/cloudfront/cloudront-OAI"

  layer                        = var.layer
  stack_id                     = var.stack_id
  configuration_cloudfront_oai = var.configuration_cloudfront_front_advantage_oai
  s3_reference                 = module.nha_s3_front_advantage.s3_reference
}

locals {

  cloudfront_origins_front_hermes = merge(var.configuration_cloudfront_front_hermes, {

    origins = [
      {
        domain_name = module.nha_s3_front_hermes.s3_reference.bucket_regional_domain_name
        origin_id   = "s3-id-${module.nha_s3_front_hermes.s3_reference.bucket}"
        s3_origin_config = {
          origin_access_identity = module.nha_cloudfront_oai_hermes.cloudfront_oai_reference.cloudfront_access_identity_path
        }
      },
    ]

    default_cache_behavior = [
      {
        target_origin_id       = "s3-id-${module.nha_s3_front_hermes.s3_reference.bucket}"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods        = ["GET", "HEAD", "OPTIONS"]
        cached_methods         = ["GET", "HEAD"]
        query_string           = false
        cookies_forward        = "none"
        headers                = []
        compress               = true
        cache_policy_id        = "Managed-CachingOptimized"
        #min_ttl                = 0
        #default_ttl            = 0
        #max_ttl                = 0
      }
    ]
  })

  cloudfront_origins_back_hermes = merge(var.configuration_cloudfront_back_hermes, {

    origins = [
      {
        domain_name = module.nha_ecs_back_hermes.alb.dns_name
        origin_id   = "ALB-${module.nha_ecs_back_hermes.alb.name}"

        custom_origin_config = {
          http_port              = 80
          https_port             = 443
          origin_read_timeout    = 60
          origin_protocol_policy = "match-viewer"
          origin_ssl_protocols   = ["TLSv1.2"]
        }
      },
    ]

    default_cache_behavior = [
      {
        target_origin_id       = "ALB-${module.nha_ecs_back_hermes.alb.name}"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods         = ["GET", "HEAD"]
        query_string           = true
        cookies_forward        = "all"
        headers = [
          "Authorization",
          "Accept",
          "Cloudfront-Viewer-Country-Region",
          "CloudFront-Viewer-Country",
          "CloudFront-Viewer-Country-Name",
          "CloudFront-Viewer-Country-Region-Name",
          "CloudFront-Viewer-Latitude",
          "CloudFront-Viewer-Longitude",
          "Host",
          "Origin"
        ]
        compress    = true
        min_ttl     = 0
        default_ttl = 0
        max_ttl     = 0
      }
    ]
  })

  cloudfront_origins_front_advantage = merge(var.configuration_cloudfront_front_advantage, {

    origins = [
      {
        domain_name = module.nha_s3_front_advantage.s3_reference.bucket_regional_domain_name
        origin_id   = "s3-id-${module.nha_s3_front_advantage.s3_reference.bucket}"
        s3_origin_config = {
          origin_access_identity = module.nha_cloudfront_oai_advantage.cloudfront_oai_reference.cloudfront_access_identity_path
        }
      },
    ]

    default_cache_behavior = [
      {
        target_origin_id       = "s3-id-${module.nha_s3_front_advantage.s3_reference.bucket}"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods        = ["GET", "HEAD", "OPTIONS"]
        cached_methods         = ["GET", "HEAD"]
        query_string           = false
        cookies_forward        = "none"
        headers                = []
        compress               = true
        cache_policy_id        = "Managed-CachingOptimized"
        #min_ttl                = 0
        #default_ttl            = 0
        #max_ttl                = 0
      }
    ]
  })

  cloudfront_origins_back_advantage = merge(var.configuration_cloudfront_back_advantage, {

    origins = [
      {
        domain_name = module.nha_ecs_back.alb.dns_name
        origin_id   = "ALB-${module.nha_ecs_back.alb.name}"

        custom_origin_config = {
          http_port              = 80
          https_port             = 443
          origin_read_timeout    = 60
          origin_protocol_policy = "match-viewer"
          origin_ssl_protocols   = ["TLSv1.2"]
        }
      },
    ]

    default_cache_behavior = [
      {
        target_origin_id       = "ALB-${module.nha_ecs_back.alb.name}"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods         = ["GET", "HEAD"]
        query_string           = true
        cookies_forward        = "all"
        headers = [
          "Authorization",
          "Accept",
          "Cloudfront-Viewer-Country-Region",
          "CloudFront-Viewer-Country",
          "CloudFront-Viewer-Country-Name",
          "CloudFront-Viewer-Country-Region-Name",
          "CloudFront-Viewer-Latitude",
          "CloudFront-Viewer-Longitude",
          "Host",
          "Origin"
        ]
        compress    = true
        min_ttl     = 0
        default_ttl = 0
        max_ttl     = 0
      }
    ]
  })

}

# Create cloudfront front hermes
module "nha_cloudfront_front_hermes" {
  source = "./modules/cloudfront"

  layer    = var.layer_2
  stack_id = var.stack_id
  # web_acl_id               = module.waf_cloudfront_front.web_acl_arn
  certificate_arn          = aws_acm_certificate.hermes_certificate_cloudfront.arn
  configuration_cloudfront = local.cloudfront_origins_front_hermes
}

# Create cloudfront back hermes
module "nha_cloudfront_back_hermes" {
  source = "./modules/cloudfront"

  layer    = var.layer_2
  stack_id = var.stack_id
  # web_acl_id               = module.waf_cloudfront.web_acl_arn
  certificate_arn          = aws_acm_certificate.hermes_certificate_cloudfront.arn
  configuration_cloudfront = local.cloudfront_origins_back_hermes
}

# Create cloudfront front hermes
module "nha_cloudfront_front_advantage" {
  source = "./modules/cloudfront"

  layer    = var.layer
  stack_id = var.stack_id
  # web_acl_id               = module.waf_cloudfront_front.web_acl_arn
  certificate_arn          = aws_acm_certificate.nha_certificate_backend_advantage_cloudfront.arn
  configuration_cloudfront = local.cloudfront_origins_front_advantage
}

# Create cloudfront back hermes
module "nha_cloudfront_back_advantage" {
  source = "./modules/cloudfront"

  layer    = var.layer
  stack_id = var.stack_id
  # web_acl_id               = module.waf_cloudfront.web_acl_arn
  certificate_arn          = aws_acm_certificate.nha_certificate_backend_advantage_cloudfront.arn
  configuration_cloudfront = local.cloudfront_origins_back_advantage
}
