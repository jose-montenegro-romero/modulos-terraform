# Create IAM access s3 hermes
resource "aws_iam_user" "user_s3_access_hermes" {
  name = "user_s3_${var.layer_2}_${var.stack_id}"

  tags = {
    environment = var.stack_id
    source      = "Terraform"
  }
}

resource "aws_iam_access_key" "user_s3_access_key_hermes" {
  user = aws_iam_user.user_s3_access_hermes.name
}

resource "aws_iam_user_policy" "user_s3_access_attach_hermes" {
  user   = aws_iam_user.user_s3_access_hermes.name
  policy = data.aws_iam_policy_document.allow_access_s3_hermes.json
}

data "aws_iam_policy_document" "allow_access_s3_hermes" {
  version   = "2008-10-17"
  policy_id = replace("PolicyAccessToS3${var.layer_2}${var.stack_id}", "_", "")
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      module.nha_s3_multimedia_hermes.s3_reference.arn,
      "${module.nha_s3_multimedia_hermes.s3_reference.arn}/*",
    ]
  }
}

# Create IAM access SES Hermes
resource "aws_iam_user" "user_ses_access_hermes" {
  name = "user_ses_${var.layer_2}_${var.stack_id}"

  tags = {
    environment = var.stack_id
    source      = "Terraform"
  }
}

resource "aws_iam_access_key" "user_ses_access_key_hermes" {
  user = aws_iam_user.user_ses_access_hermes.name
}

resource "aws_iam_user_policy" "user_ses_access_attach_hermes" {
  user   = aws_iam_user.user_ses_access_hermes.name
  policy = data.aws_iam_policy_document.allow_access_ses_hermes.json
}

data "aws_iam_policy_document" "allow_access_ses_hermes" {
  version   = "2012-10-17"
  policy_id = replace("PolicyAccessToSES${var.layer_2}${var.stack_id}", "_", "")
  statement {
    effect = "Allow"
    actions = [
      "ses:SendRawEmail",
    ]
    resources = [
      "*"
    ]
  }
}

///////////////////////////////////////////////////////
/////////////// ADVANTAGE      ////////////////////////
///////////////////////////////////////////////////////

# Create IAM access s3
resource "aws_iam_user" "user_s3_access" {
  name = "user_s3_${var.layer}_${var.stack_id}"

  tags = {
    environment = var.stack_id
    source      = "Terraform"
  }
}

resource "aws_iam_access_key" "user_s3_access_key" {
  user = aws_iam_user.user_s3_access.name
}

resource "aws_iam_user_policy" "user_s3_access_attach" {
  user   = aws_iam_user.user_s3_access.name
  policy = data.aws_iam_policy_document.allow_access_s3.json
}

data "aws_iam_policy_document" "allow_access_s3" {
  version   = "2008-10-17"
  policy_id = replace("PolicyAccessToS3${var.layer}${var.stack_id}", "_", "")
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      module.nha_s3_multimedia_advantage.s3_reference.arn,
      "${module.nha_s3_multimedia_advantage.s3_reference.arn}/*",
    ]
  }
}

# Create IAM access SES
resource "aws_iam_user" "user_ses_access" {
  name = "user_ses_${var.layer}_${var.stack_id}"

  tags = {
    environment = var.stack_id
    source      = "Terraform"
  }
}

resource "aws_iam_access_key" "user_ses_access_key" {
  user = aws_iam_user.user_ses_access.name
}

resource "aws_iam_user_policy" "user_ses_access_attach" {
  user   = aws_iam_user.user_ses_access.name
  policy = data.aws_iam_policy_document.allow_access_ses.json
}

data "aws_iam_policy_document" "allow_access_ses" {
  version   = "2012-10-17"
  policy_id = replace("PolicyAccessToSES${var.layer}${var.stack_id}", "_", "")
  statement {
    effect = "Allow"
    actions = [
      "ses:SendRawEmail",
    ]
    resources = [
      "*"
    ]
  }
}
