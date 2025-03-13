resource "aws_s3_bucket" "s3" {
  bucket = replace("${lookup(var.configuration_s3, "bucket_name")}-${var.layer}-${var.stack_id}", "_", "-")
  acl    = "private"

  tags = {
    Name        = "${lookup(var.configuration_s3, "bucket_name")}_${var.layer}_${var.stack_id}"
    environment = var.stack_id
    source      = "Terraform"
  }
}

data "aws_iam_policy_document" "s3_policy" {
  version   = "2008-10-17"
  policy_id = "PolicyForCloudFrontPrivateContent"
  statement {
    sid       = "1"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.s3_distribution_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "s3_public_access_block" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = lookup(var.configuration_s3, "block_public_acls", false)
  block_public_policy     = lookup(var.configuration_s3, "block_public_policy", false)
  ignore_public_acls      = lookup(var.configuration_s3, "ignore_public_acls", false)
  restrict_public_buckets = lookup(var.configuration_s3, "restrict_public_buckets", false)
}
resource "aws_cloudfront_origin_access_identity" "s3_distribution_oai" {
  comment = "OAI_${lookup(var.configuration_s3, "bucket_name")}_${var.layer}_${var.stack_id}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3.bucket_regional_domain_name
    origin_id   = "s3-${aws_s3_bucket.s3.bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_distribution_oai.cloudfront_access_identity_path
    }
  }

  aliases         = var.certificate_arn != null ? lookup(var.configuration_s3, "aliases") : []
  enabled         = true
  is_ipv6_enabled = false
  comment         = "${lookup(var.configuration_s3, "bucket_name")}_${var.layer}_${var.stack_id}"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "s3-${aws_s3_bucket.s3.bucket}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    compress    = true
    min_ttl     = lookup(var.configuration_s3, "min_ttl", 0)
    default_ttl = lookup(var.configuration_s3, "default_ttl", 0)
    max_ttl     = lookup(var.configuration_s3, "max_ttl", 0)
  }

  viewer_certificate {
    acm_certificate_arn            = var.certificate_arn
    ssl_support_method             = var.certificate_arn != null ? lookup(var.configuration_s3, "ssl_support_method", "sni-only") : null
    minimum_protocol_version       = var.certificate_arn != null ? lookup(var.configuration_s3, "minimum_protocol_version", "TLSv1.2_2021") : null
    cloudfront_default_certificate = var.certificate_arn != null ? false : true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "${lookup(var.configuration_s3, "bucket_name")}_${var.layer}_${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  }
}
