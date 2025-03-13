resource "aws_ssm_parameter" "ssm_google_recaptcha_hermes" {
  name  = "/${var.stack_id}/GOOGLE/G_SECRET_RECAPTCHA_HERMES"
  type  = "SecureString"
  value = var.ssm_google_recaptcha_hermes

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "app_debug" {
  name  = "/${var.stack_id}/APP/APP_DEBUG"
  type  = "String"
  value = "false"

  tags = {
    Source = "Terraform"
  }
}

# DB environments
resource "aws_ssm_parameter" "db_connection" {
  name  = "/${var.stack_id}/RDS/DB_CONNECTION"
  type  = "String"
  value = "mysql"

  tags = {
    Source = "Terraform"
  }
}

# SES environments
resource "aws_ssm_parameter" "secret_password_ses_hermes" {
  name  = "/${var.stack_id}/SES/MAIL_PASSWORD_HERMES"
  type  = "SecureString"
  value = aws_iam_access_key.user_ses_access_key_hermes.ses_smtp_password_v4

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_user_ses_hermes" {
  name  = "/${var.stack_id}/SES/MAIL_USERNAME_HERMES"
  type  = "SecureString"
  value = aws_iam_access_key.user_ses_access_key_hermes.id

  tags = {
    Source = "Terraform"
  }
}
resource "aws_ssm_parameter" "mail_driver_hermes" {
  name  = "/${var.stack_id}/SES/MAIL_DRIVER_HERMES"
  type  = "String"
  value = "smtp"

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "mail_host_hermes" {
  name  = "/${var.stack_id}/SES/MAIL_HOST_HERMES"
  type  = "String"
  value = "email-smtp.us-west-1.amazonaws.com"

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "mail_port_hermes" {
  name  = "/${var.stack_id}/SES/MAIL_PORT_HERMES"
  type  = "String"
  value = "587"

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "mail_encryption_hermes" {
  name  = "/${var.stack_id}/SES/MAIL_ENCRYPTION_HERMES"
  type  = "String"
  value = "tls"

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "mail_from_address_hermes" {
  name  = "/${var.stack_id}/SES/MAIL_FROM_ADDRESS_HERMES"
  type  = "String"
  value = "support@hermesfantasy.app"

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "mail_from_name_hermes" {
  name  = "/${var.stack_id}/SES/MAIL_FROM_NAME_HERMES"
  type  = "String"
  value = "Hermes fantasy"

  tags = {
    Source = "Terraform"
  }
}

# S3 crendentials environments Hermes
resource "aws_ssm_parameter" "ssm_user_s3_key_hermes" {
  name  = "/${var.stack_id}/S3/USER_S3_ACCESS_KEY_ID_HERMES"
  type  = "SecureString"
  value = aws_iam_access_key.user_s3_access_key_hermes.id

  tags = {
    Source = "Terraform"
  }
}


resource "aws_ssm_parameter" "ssm_user_s3_access_key_hermes" {
  name  = "/${var.stack_id}/S3/USER_S3_ACCESS_KEY_SECRET_HERMES"
  type  = "SecureString"
  value = aws_iam_access_key.user_s3_access_key_hermes.secret

  tags = {
    Source = "Terraform"
  }
}


resource "aws_ssm_parameter" "ssm_user_s3_region_hermes" {
  name  = "/${var.stack_id}/S3/USER_S3_REGION_HERMES"
  type  = "String"
  value = var.aws_region

  tags = {
    Source = "Terraform"
  }
}


resource "aws_ssm_parameter" "ssm_user_s3_bucket_name_hermes" {
  name  = "/${var.stack_id}/S3/USER_S3_BUCKET_NAME_HERMES"
  type  = "String"
  value = module.nha_s3_multimedia_hermes.s3_reference.id

  tags = {
    Source = "Terraform"
  }
}


resource "aws_ssm_parameter" "ssm_user_s3_cdn_hermes" {
  name  = "/${var.stack_id}/S3/USER_S3_CDN_HERMES"
  type  = "String"
  value = "https://${var.configuration_acm_multimedia_hermes.domain_name}"

  tags = {
    Source = "Terraform"
  }
}

///////////////////////////////////////////////////////
/////////////// ADVANTAGE      ////////////////////////
///////////////////////////////////////////////////////

resource "aws_ssm_parameter" "ssm_google_recaptcha_advantage" {
  name  = "/${var.stack_id}/GOOGLE/G_SECRET_RECAPTCHA"
  type  = "SecureString"
  value = var.ssm_google_recaptcha_advantage

  tags = {
    Source = "Terraform"
  }
}

# SES environments
resource "aws_ssm_parameter" "secret_password_ses" {
  name  = "/${var.stack_id}/SES/MAIL_PASSWORD"
  type  = "SecureString"
  value = aws_iam_access_key.user_ses_access_key.ses_smtp_password_v4

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "secret_user_ses" {
  name  = "/${var.stack_id}/SES/MAIL_USERNAME"
  type  = "SecureString"
  value = aws_iam_access_key.user_ses_access_key.id

  tags = {
    Source = "Terraform"
  }
}
resource "aws_ssm_parameter" "mail_driver" {
  name  = "/${var.stack_id}/SES/MAIL_DRIVER"
  type  = "String"
  value = "smtp"

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "mail_host" {
  name  = "/${var.stack_id}/SES/MAIL_HOST"
  type  = "String"
  value = "email-smtp.us-west-1.amazonaws.com"

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "mail_port" {
  name  = "/${var.stack_id}/SES/MAIL_PORT"
  type  = "String"
  value = "587"

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "mail_encryption" {
  name  = "/${var.stack_id}/SES/MAIL_ENCRYPTION"
  type  = "String"
  value = "tls"

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "mail_from_address" {
  name  = "/${var.stack_id}/SES/MAIL_FROM_ADDRESS"
  type  = "String"
  value = "support@advantageapp.com"

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "mail_from_name" {
  name  = "/${var.stack_id}/SES/MAIL_FROM_NAME"
  type  = "String"
  value = "Advantage"

  tags = {
    Source = "Terraform"
  }
}

# S3 crendentials environments
resource "aws_ssm_parameter" "ssm_user_s3_key" {
  name  = "/${var.stack_id}/S3/USER_S3_ACCESS_KEY_ID"
  type  = "SecureString"
  value = aws_iam_access_key.user_s3_access_key.id

  tags = {
    Source = "Terraform"
  }
}


resource "aws_ssm_parameter" "ssm_user_s3_access_key" {
  name  = "/${var.stack_id}/S3/USER_S3_ACCESS_KEY_SECRET"
  type  = "SecureString"
  value = aws_iam_access_key.user_s3_access_key.secret

  tags = {
    Source = "Terraform"
  }
}


resource "aws_ssm_parameter" "ssm_user_s3_region" {
  name  = "/${var.stack_id}/S3/USER_S3_REGION"
  type  = "String"
  value = var.aws_region

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "ssm_user_s3_bucket_name" {
  name  = "/${var.stack_id}/S3/USER_S3_BUCKET_NAME"
  type  = "String"
  value = module.nha_s3_multimedia_advantage.s3_reference.id

  tags = {
    Source = "Terraform"
  }
}

resource "aws_ssm_parameter" "ssm_user_s3_cdn" {
  name  = "/${var.stack_id}/S3/USER_S3_CDN"
  type  = "String"
  value = "https://${var.configuration_acm_multimedia_advantage.domain_name}"

  tags = {
    Source = "Terraform"
  }
}
