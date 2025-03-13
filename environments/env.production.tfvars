/* environment  */
stack_id   = "production"
layer      = "nha2"
layer_2    = "hermes2"
aws_region = "us-west-1"

/* network */
vpc_cidr        = "10.1.0.0/22"
subnets_public  = ["10.1.0.0/24", "10.1.1.0/24"]
subnets_private = ["10.1.2.0/24", "10.1.3.0/24"]

/* SSM */
ssm_google_recaptcha_hermes    = "6LfjwvEmAAAAADYNKXGj1rDGZN-kwY0DKgwufE4H"
ssm_google_recaptcha_advantage = "6Lew1oInAAAAAFjtCCnkDIF-2GjLclasuHjR0Efs"

/* CERTIFICATE MANAGER*/
configuration_acm_hermes = {
  domain_name               = "web.hermesfantasy.app"
  subject_alternative_names = ["webadmin.hermesfantasy.app"]
  validation_method         = "DNS"
  tags = {
    Environment = "production"
    Source      = "Terraform"
  }

}

configuration_acm_multimedia_hermes = {
  domain_name               = "multimedia.hermesfantasy.app"
  subject_alternative_names = null
  validation_method         = "DNS"
  tags = {
    Environment = "production"
    Source      = "Terraform"
  }

}

configuration_acm_wordpress_advantage = {
  domain_name               = "www.advantageapp.com"
  subject_alternative_names = ["advantageapp.com"]
  validation_method         = "DNS"
  tags = {
    Environment = "production"
    Source      = "Terraform"
  }
}

configuration_acm_backend_advantage = {
  domain_name               = "web.advantageapp.com"
  subject_alternative_names = ["webadmin.advantageapp.com"]
  validation_method         = "DNS"
  tags = {
    Environment = "production"
    Source      = "Terraform"
  }
}

configuration_acm_multimedia_advantage = {
  domain_name               = "multimedia.advantageapp.com"
  subject_alternative_names = null
  validation_method         = "DNS"
  tags = {
    Environment = "production"
    Source      = "Terraform"
  }

}
# /* BASTION  */

configuration_ec2_bastion = {
  name_ec2                = "bastion"
  ami                     = "ami-017c001a88dd93847"
  instance_type           = "t2.nano"
  disable_api_termination = "true"
  public_key              = "./keypem/nha-production.pem.pub"
  ingress = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

/* CODEPIPELINE  */
configuration_codepipeline_terraform = {
  repository_name        = "nohouseadvantage/devops-spanish"
  repository_branch_name = "production"
  environment_variable = [
    {
      name  = "ENVIRONMENT_NAME"
      value = "production"
    },
    {
      name  = "TERRAFORM_VERSION"
      value = "1.5.4"
    }
  ]
}

configuration_pipeline_front_hermes = {
  repository_name         = "nohouseadvantage/web-spanish"
  repository_branch_names = "production"
  CacheControl            = "max-age=0"
  compute_type            = "BUILD_GENERAL1_MEDIUM",
  enabled_clear_cache     = true
  buildspec_cache_clear   = "./template-buildspec/s3-buildspec.yml"
  environment_variable = [
    {
      name  = "ENVIRONMENT_NAME"
      value = "production"
    }
  ]
}

configuration_pipeline_back_hermes = {
  repository_name         = "nohouseadvantage/backend-spanish"
  repository_branch_names = "production"
  enabled_automation      = false
}

configuration_pipeline_wordpress_advantage = {
  repository_name         = "nohouseadvantage/web-wp"
  repository_branch_names = "production_advantage"
  enabled_automation      = false
}

configuration_pipeline_front_advantage = {
  repository_name         = "nohouseadvantage/web"
  repository_branch_names = "production2"
  CacheControl            = "max-age=0"
  compute_type            = "BUILD_GENERAL1_MEDIUM",
  enabled_clear_cache     = true
  buildspec_cache_clear   = "./template-buildspec/s3-buildspec.yml"
  environment_variable = [
    {
      name  = "ENVIRONMENT_NAME"
      value = "production"
    }
  ]
}

configuration_pipeline_back_advantage = {
  repository_name         = "nohouseadvantage/backend"
  repository_branch_names = "production2"
  enabled_automation      = false
}

/* S3 PageStatic*/

configuration_front_hermes = {
  bucket_name    = "front-hermes"
  index_document = "index.html"
  error_document = "index.html"
}

configuration_multimedia_hermes = {
  bucket_name = "multimedia"
  aliases     = ["multimedia.hermesfantasy.app"]

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  min_ttl     = 0
  default_ttl = 1296000
  max_ttl     = 2592000
}

configuration_front_advantage = {
  bucket_name    = "front-advantage"
  index_document = "index.html"
  error_document = "index.html"
}

configuration_multimedia_advantage = {
  bucket_name = "multimedia-advantage"
  aliases     = ["multimedia.advantageapp.com"]

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  min_ttl     = 0
  default_ttl = 1296000
  max_ttl     = 2592000
}

/* CLOUDFRONT */

configuration_cloudfront_front_hermes_oai = {
  name = "OAI_cloudfront_front_hermes"
}

configuration_cloudfront_front_advantage_oai = {
  name = "OAI_cloudfront_front_advantage"
}

configuration_cloudfront_front_hermes = {
  cloudfront_name          = "cloudfront_front"
  aliases                  = ["web.hermesfantasy.app"]
  ssl_support_method       = "sni-only"
  minimum_protocol_version = "TLSv1.2_2019"

  custom_error_response = [
    {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
    }
  ]
}

configuration_cloudfront_back_hermes = {
  cloudfront_name          = "cloudfront_back"
  aliases                  = ["webadmin.hermesfantasy.app"]
  ssl_support_method       = "sni-only"
  minimum_protocol_version = "TLSv1.2_2019"
}

configuration_cloudfront_front_advantage = {
  cloudfront_name          = "cloudfront_front"
  aliases                  = ["web.advantageapp.com"]
  ssl_support_method       = "sni-only"
  minimum_protocol_version = "TLSv1.2_2019"

  custom_error_response = [
    {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
    }
  ]
}

configuration_cloudfront_back_advantage = {
  cloudfront_name          = "cloudfront_back"
  aliases                  = ["webadmin.advantageapp.com"]
  ssl_support_method       = "sni-only"
  minimum_protocol_version = "TLSv1.2_2019"
}

/* ECS */

configuration_ecs_back_hermes = {
  ecs_fargate = [
    {
      ecr_repository       = "back-hermes"
      health_check_path    = "/status"
      cpu                  = "4096"
      memory               = "8192"
      port                 = 80
      min_capacity_fargate = 1
      max_capacity_fargate = 1
      templatefile         = "./templatesEcs/back-production-hermes.json"
      volume = {
        root_directory     = "/"
        transit_encryption = "ENABLED"
      }
    }
  ]
  listener_rule_fargate = [
    {
      type         = "forward"
      target_group = 0
      host_header  = ["webadmin.hermesfantasy.app"]
    }
  ]
  extra_environments = {
    "containerPath" : "/var/www/html/app/storage/logs"
    "sourceVolume" : "efs-back-hermes-production"
  }
}

configuration_ecs_wordpress_advantage = {
  ecs_fargate = [
    {
      ecr_repository       = "full-wordpress"
      health_check_path    = "/"
      matcher              = "200,301"
      cpu                  = "256"
      memory               = "512"
      port                 = 80
      min_capacity_fargate = 1
      max_capacity_fargate = 1
      templatefile         = "./templatesEcs/wordpress-advantage-production.json"
    }
  ]
  listener_rule_fargate = [
    {
      type         = "forward"
      target_group = 0
      host_header  = ["www.advantageapp.com", "advantageapp.com"]
    }
  ]
  extra_environments = {
    "DB_NAME" : "advantage"
  }
}

configuration_ecs_back_advantage = {
  ecs_fargate = [
    {
      ecr_repository       = "back-advantage"
      health_check_path    = "/status"
      cpu                  = "2048"
      memory               = "4096"
      port                 = 80
      min_capacity_fargate = 1
      max_capacity_fargate = 10
      templatefile         = "./templatesEcs/back-production.json"
    }
  ]
  listener_rule_fargate = [
    {
      type         = "forward"
      target_group = 0
      host_header  = ["webadmin.advantageapp.com"]
    }
  ]
}

/* EFS */
configuration_efs_back_hermes = {
  creation_token   = "efs_back"
  performance_mode = "generalPurpose"
  backup           = false
  efs_access_point = {
    access_point = true
    posix_user = {
      gid = 1000
      uid = 1000
    }
    root_directory = {
      path = "/app/storage/logs"
      creation_info = {
        owner_gid   = 1000
        owner_uid   = 1000
        permissions = "0755"
      }
    }
  }

}


/* RDS DATABASE  */

configuration_rds_aurora_mysql_hermes = {
  rds_name                = "rds-aurora"
  engine_version          = "8.0.mysql_aurora.3.03.1"
  engine_mode             = "provisioned"
  engine                  = "aurora-mysql"
  backup_retention_period = 5
  database_name           = "webadmin"
  master_username         = "admin"
  serverlessv2_scaling_configuration = {
    min_capacity = 2.0
    max_capacity = 4.0
  }

  ingress = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  parameters = [
    {
      name  = "character_set_server"
      value = "utf8"
    },
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "log_bin_trust_function_creators"
      value = "1"
    },
    {
      name  = "aurora_parallel_query"
      value = "1"
    }
  ]
}

configuration_rds_aurora_mysql_advantage = {
  rds_name                = "rds-advantage"
  engine_version          = "8.0.mysql_aurora.3.03.1"
  engine_mode             = "provisioned"
  engine                  = "aurora-mysql"
  backup_retention_period = 1
  database_name           = "advantage"
  master_username         = "admin"
  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 1.0
  }

  ingress = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  parameters = [
    {
      name  = "character_set_server"
      value = "utf8"
    },
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "log_bin_trust_function_creators"
      value = "1"
    },
    {
      name  = "aurora_parallel_query"
      value = "1"
    }
  ]
}

configuration_rds_aurora_mysql_back_advantage = {
  rds_name                = "back-advantage"
  engine_version          = "8.0.mysql_aurora.3.03.1"
  engine_mode             = "provisioned"
  engine                  = "aurora-mysql"
  backup_retention_period = 1
  database_name           = "webadmin"
  master_username         = "admin"
  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 1.0
  }

  ingress = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  parameters = [
    {
      name  = "character_set_server"
      value = "utf8"
    },
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "log_bin_trust_function_creators"
      value = "1"
    },
    {
      name  = "aurora_parallel_query"
      value = "1"
    }
  ]
}
