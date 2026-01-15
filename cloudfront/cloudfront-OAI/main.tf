resource "aws_cloudfront_origin_access_identity" "cloudfront_origin_access_identity" {
  comment = "${lookup(var.configuration_cloudfront_oai, "name")}_${var.project}_${var.environment}"
}

data "aws_iam_policy_document" "s3_policy" {
  version   = "2008-10-17"
  policy_id = replace("${lookup(var.configuration_cloudfront_oai, "name")}PolicyForCloudFrontPrivateContent", "_", "")
  statement {
    sid       = "1"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${var.s3_reference.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = var.s3_reference.id
  policy = data.aws_iam_policy_document.s3_policy.json
}
