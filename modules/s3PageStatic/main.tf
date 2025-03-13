resource "aws_s3_bucket" "s3" {
  bucket = replace("${lookup(var.configuration_s3, "bucket_name")}-${var.layer}-${var.stack_id}", "_", "-")
  acl    = lookup(var.configuration_s3, "acl", "private")

  tags = {
    Name        = "${lookup(var.configuration_s3, "bucket_name")}_${var.layer}_${var.stack_id}"
    environment = var.stack_id
    source      = "Terraform"
  }

  website {
    index_document = lookup(var.configuration_s3, "index_document", "index.html")
    error_document = lookup(var.configuration_s3, "error_document", "index.html")
  }
}

resource "aws_s3_bucket_public_access_block" "s3_public_access_block" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = lookup(var.configuration_s3, "block_public_acls", false)
  block_public_policy     = lookup(var.configuration_s3, "block_public_policy", false)
  ignore_public_acls      = lookup(var.configuration_s3, "ignore_public_acls", false)
  restrict_public_buckets = lookup(var.configuration_s3, "restrict_public_buckets", false)
}
