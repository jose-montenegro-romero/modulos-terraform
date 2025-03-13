resource "aws_codestarconnections_connection" "devops" {
  name          = "nohouseadvantage"
  provider_type = "GitHub"
}

/* Create Codepipeline For terraform deploy infrastructure */
module "nha_codepipeline_terraform" {
  source = "./modules/terraform-pipeline"

  layer                                = var.layer
  stack_id                             = var.stack_id
  configuration_codepipeline_terraform = var.configuration_codepipeline_terraform
  ConnectionArn                        = aws_codestarconnections_connection.devops.arn
}

# Create CodePipeLine S3 front hermes
module "nha_pipeline_s3_front_hermes" {
  source = "./modules/codePipeLineS3"

  layer                   = "${var.layer_2}-front"
  stack_id                = var.stack_id
  region                  = var.aws_region
  db_subnets_private      = module.nha_network.subnets_private
  vpc                     = module.nha_network.vpc.id
  repository_name         = lookup(var.configuration_pipeline_front_hermes, "repository_name")
  repository_branch_names = lookup(var.configuration_pipeline_front_hermes, "repository_branch_names")
  BucketName              = module.nha_s3_front_hermes.s3_reference.bucket
  CacheControl            = lookup(var.configuration_pipeline_front_hermes, "CacheControl", null)
  ConnectionArn           = aws_codestarconnections_connection.devops.arn
  cloudfront_id           = module.nha_cloudfront_front_hermes.cloudfront_reference.id
  compute_type            = lookup(var.configuration_pipeline_front_hermes, "compute_type")
  environment_variable    = lookup(var.configuration_pipeline_front_hermes, "environment_variable")
  enabled_clear_cache     = lookup(var.configuration_pipeline_front_hermes, "enabled_clear_cache")
  buildspec_cache_clear   = lookup(var.configuration_pipeline_front_hermes, "buildspec_cache_clear")
}

/* Create Codepipeline For backend hermes */
module "nha_codepipeline_backend_hermes" {
  source = "./modules/codePipeLineECS"

  layer                   = "${var.layer_2}-back"
  stack_id                = var.stack_id
  region                  = var.aws_region
  repository_url          = module.nha_ecs_back_hermes.aws_ecr_repository[0].repository_url
  db_subnets_private      = module.nha_network.subnets_private
  vpc                     = module.nha_network.vpc.id
  security_group_ids      = ["${module.nha_ecs_back_hermes.aws_security_group_alb.id}"]
  repository_name         = lookup(var.configuration_pipeline_back_hermes, "repository_name")
  repository_branch_names = lookup(var.configuration_pipeline_back_hermes, "repository_branch_names")
  cluster_name            = module.nha_ecs_back_hermes.aws_ecs_cluster.name
  service_name            = module.nha_ecs_back_hermes.aws_ecs_service[0].name
  container_name          = "container_${lookup(element(var.configuration_ecs_back_hermes.ecs_fargate, 0), "ecr_repository")}_${var.stack_id}"
  ConnectionArn           = aws_codestarconnections_connection.devops.arn
  enabled_automation      = lookup(var.configuration_pipeline_back_hermes, "enabled_automation")
}

/* Create Codepipeline For wordpress advantage */
module "nha_codepipeline_wordpress_advantage" {

  source = "./modules/codePipeLineECS"

  layer                   = "${var.layer}-wadvantage"
  stack_id                = var.stack_id
  region                  = var.aws_region
  repository_url          = module.nha_ecs_wordpress_advantage.aws_ecr_repository[0].repository_url
  db_subnets_private      = module.nha_network.subnets_private
  vpc                     = module.nha_network.vpc.id
  security_group_ids      = ["${module.nha_ecs_wordpress_advantage.aws_security_group_alb.id}"]
  repository_name         = lookup(var.configuration_pipeline_wordpress_advantage, "repository_name")
  repository_branch_names = lookup(var.configuration_pipeline_wordpress_advantage, "repository_branch_names")
  cluster_name            = module.nha_ecs_wordpress_advantage.aws_ecs_cluster.name
  service_name            = module.nha_ecs_wordpress_advantage.aws_ecs_service[0].name
  container_name          = "container_${lookup(element(var.configuration_ecs_wordpress_advantage.ecs_fargate, 0), "ecr_repository")}_${var.stack_id}"
  ConnectionArn           = aws_codestarconnections_connection.devops.arn
  enabled_automation      = lookup(var.configuration_pipeline_wordpress_advantage, "enabled_automation")
  environment_variable    = []
}

# Create CodePipeLine S3 front advantage
module "nha_pipeline_s3_front_advantage" {
  source = "./modules/codePipeLineS3"

  layer                   = "${var.layer_2}-front-advantage"
  stack_id                = var.stack_id
  region                  = var.aws_region
  db_subnets_private      = module.nha_network.subnets_private
  vpc                     = module.nha_network.vpc.id
  repository_name         = lookup(var.configuration_pipeline_front_advantage, "repository_name")
  repository_branch_names = lookup(var.configuration_pipeline_front_advantage, "repository_branch_names")
  BucketName              = module.nha_s3_front_advantage.s3_reference.bucket
  CacheControl            = lookup(var.configuration_pipeline_front_advantage, "CacheControl", null)
  ConnectionArn           = aws_codestarconnections_connection.devops.arn
  cloudfront_id           = module.nha_cloudfront_front_advantage.cloudfront_reference.id
  compute_type            = lookup(var.configuration_pipeline_front_advantage, "compute_type")
  environment_variable    = lookup(var.configuration_pipeline_front_advantage, "environment_variable")
  enabled_clear_cache     = lookup(var.configuration_pipeline_front_advantage, "enabled_clear_cache")
  buildspec_cache_clear   = lookup(var.configuration_pipeline_front_advantage, "buildspec_cache_clear")
}

/* Create Codepipeline For backend advantage */
module "nha_codepipeline_backend_advantage" {
  source = "./modules/codePipeLineECS"

  layer                   = "${var.layer}-back-advantage"
  stack_id                = var.stack_id
  region                  = var.aws_region
  repository_url          = module.nha_ecs_back.aws_ecr_repository[0].repository_url
  db_subnets_private      = module.nha_network.subnets_private
  vpc                     = module.nha_network.vpc.id
  security_group_ids      = ["${module.nha_ecs_back.aws_security_group_alb.id}"]
  repository_name         = lookup(var.configuration_pipeline_back_advantage, "repository_name")
  repository_branch_names = lookup(var.configuration_pipeline_back_advantage, "repository_branch_names")
  cluster_name            = module.nha_ecs_back.aws_ecs_cluster.name
  service_name            = module.nha_ecs_back.aws_ecs_service[0].name
  container_name          = "container_${lookup(element(var.configuration_ecs_back_advantage.ecs_fargate, 0), "ecr_repository")}_${var.stack_id}"
  ConnectionArn           = aws_codestarconnections_connection.devops.arn
  enabled_automation      = lookup(var.configuration_pipeline_back_advantage, "enabled_automation")
}
