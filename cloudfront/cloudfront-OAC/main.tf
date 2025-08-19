resource "aws_cloudfront_origin_access_control" "cloudfront_origin_access_control" {
  name                              = replace("${var.name}-${var.layer}-${var.stack_id}", "_", "-" )
  description                       = "OAC ${var.name} ${var.layer} ${var.stack_id}"
  origin_access_control_origin_type = var.origin_access_control_origin_type
  signing_behavior                  = var.signing_behavior
  signing_protocol                  = var.signing_protocol
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions = [ "s3:GetObject" ]
    resources = [ "${var.s3_reference.arn}/*" ]
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [var.cloudfront_reference.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy_oac" {
  bucket = var.s3_reference.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

