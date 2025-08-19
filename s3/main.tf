resource "aws_s3_bucket" "s3" {
  bucket = var.custom_name != null ? var.custom_name : replace("${var.name}-${var.layer}-${var.stack_id}", "_", "-")

  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name        = "${var.name}-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    source      = "Terraform"
  })
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_ownership_controls" {
  bucket = aws_s3_bucket.s3.id
  rule {
    object_ownership = var.s3_bucket_ownership_controls_rule.object_ownership
  }
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {

  count = var.s3_bucket_ownership_controls_rule.object_ownership != "BucketOwnerEnforced" ? 1 : 0

  bucket = aws_s3_bucket.s3.id
  acl    = var.s3_bucket_acl.acl

  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_ownership_controls]
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3.id
  versioning_configuration {
    status = var.s3_bucket_versioning.status
  }
}

resource "aws_s3_bucket_website_configuration" "s3_bucket_website_configuration" {

  count = var.s3_bucket_website_configuration == null ? 0 : 1

  bucket = aws_s3_bucket.s3.id

  index_document {
    suffix = var.s3_bucket_website_configuration.index_document_suffix
  }

  error_document {
    key = var.s3_bucket_website_configuration.error_document_key
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = var.s3_bucket_public_access_block.block_public_acls
  block_public_policy     = var.s3_bucket_public_access_block.block_public_policy
  ignore_public_acls      = var.s3_bucket_public_access_block.ignore_public_acls
  restrict_public_buckets = var.s3_bucket_public_access_block.restrict_public_buckets
}
