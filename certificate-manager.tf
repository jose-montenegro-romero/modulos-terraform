///////////////////////////////////////////////////////
/////////////// HERMES FANTASY ////////////////////////
///////////////////////////////////////////////////////

# Create certificate Cloudfront
resource "aws_acm_certificate" "hermes_certificate_cloudfront" {

  provider = aws.east

  domain_name               = lookup(var.configuration_acm_hermes, "domain_name")
  subject_alternative_names = lookup(var.configuration_acm_hermes, "subject_alternative_names")
  validation_method         = lookup(var.configuration_acm_hermes, "validation_method")

  tags = lookup(var.configuration_acm_hermes, "tags")

  lifecycle {
    create_before_destroy = true
  }
}

# Create certificate 
resource "aws_acm_certificate" "hermes_certificate" {

  domain_name               = lookup(var.configuration_acm_hermes, "domain_name")
  subject_alternative_names = lookup(var.configuration_acm_hermes, "subject_alternative_names")
  validation_method         = lookup(var.configuration_acm_hermes, "validation_method")

  tags = lookup(var.configuration_acm_hermes, "tags")

  lifecycle {
    create_before_destroy = true
  }
}

# Create certificate Cloudfront multimedia hermes
resource "aws_acm_certificate" "hermes_certificate_cloudfront_multimedia" {

  provider = aws.east

  domain_name               = lookup(var.configuration_acm_multimedia_hermes, "domain_name")
  subject_alternative_names = lookup(var.configuration_acm_multimedia_hermes, "subject_alternative_names")
  validation_method         = lookup(var.configuration_acm_multimedia_hermes, "validation_method")

  tags = lookup(var.configuration_acm_multimedia_hermes, "tags")

  lifecycle {
    create_before_destroy = true
  }
}

///////////////////////////////////////////////////////
/////////////// Advantage      ////////////////////////
///////////////////////////////////////////////////////

# Create certificate cloudfront wordpress advantage
resource "aws_acm_certificate" "nha_certificate_wordpress_advantage" {

  domain_name               = lookup(var.configuration_acm_wordpress_advantage, "domain_name")
  subject_alternative_names = lookup(var.configuration_acm_wordpress_advantage, "subject_alternative_names")
  validation_method         = lookup(var.configuration_acm_wordpress_advantage, "validation_method")

  tags = lookup(var.configuration_acm_wordpress_advantage, "tags")

  lifecycle {
    create_before_destroy = true
  }
}

# Create certificate cloudfront backend advantage
resource "aws_acm_certificate" "nha_certificate_backend_advantage" {

  domain_name               = lookup(var.configuration_acm_backend_advantage, "domain_name")
  subject_alternative_names = lookup(var.configuration_acm_backend_advantage, "subject_alternative_names")
  validation_method         = lookup(var.configuration_acm_backend_advantage, "validation_method")

  tags = lookup(var.configuration_acm_backend_advantage, "tags")

  lifecycle {
    create_before_destroy = true
  }
}

# Create certificate cloudfront backend advantage
resource "aws_acm_certificate" "nha_certificate_backend_advantage_cloudfront" {

  provider = aws.east

  domain_name               = lookup(var.configuration_acm_backend_advantage, "domain_name")
  subject_alternative_names = lookup(var.configuration_acm_backend_advantage, "subject_alternative_names")
  validation_method         = lookup(var.configuration_acm_backend_advantage, "validation_method")

  tags = lookup(var.configuration_acm_backend_advantage, "tags")

  lifecycle {
    create_before_destroy = true
  }
}

# Create certificate Cloudfront multimedia advantage
resource "aws_acm_certificate" "advantage_certificate_cloudfront_multimedia" {

  provider = aws.east

  domain_name               = lookup(var.configuration_acm_multimedia_advantage, "domain_name")
  subject_alternative_names = lookup(var.configuration_acm_multimedia_advantage, "subject_alternative_names")
  validation_method         = lookup(var.configuration_acm_multimedia_advantage, "validation_method")

  tags = lookup(var.configuration_acm_multimedia_advantage, "tags")

  lifecycle {
    create_before_destroy = true
  }
}
