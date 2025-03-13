# Create s3 - cloudfront page static front hermes
module "nha_s3_front_hermes" {

  source = "./modules/s3PageStatic"

  layer            = var.layer
  stack_id         = var.stack_id
  configuration_s3 = var.configuration_front_hermes

}

# Create s3 - multimedia hermes
module "nha_s3_multimedia_hermes" {
  source = "./modules/s3Cloudfront"

  layer            = var.layer_2
  stack_id         = var.stack_id
  configuration_s3 = var.configuration_multimedia_hermes
  certificate_arn  = aws_acm_certificate.hermes_certificate_cloudfront_multimedia.arn
}

# Create s3 - cloudfront page static front advantage
module "nha_s3_front_advantage" {

  source = "./modules/s3PageStatic"

  layer            = var.layer
  stack_id         = var.stack_id
  configuration_s3 = var.configuration_front_advantage

}

# Create s3 - multimedia advantage
module "nha_s3_multimedia_advantage" {
  source = "./modules/s3Cloudfront"

  layer            = var.layer
  stack_id         = var.stack_id
  configuration_s3 = var.configuration_multimedia_advantage
  certificate_arn  = aws_acm_certificate.advantage_certificate_cloudfront_multimedia.arn
}
