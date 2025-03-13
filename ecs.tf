locals {
  ecs_back_hermes_environments_concat = merge(lookup(var.configuration_ecs_back_hermes, "extra_environments", {}), {
  })
  ecs_wordpress_advantage_environments_concat = merge(lookup(var.configuration_ecs_wordpress_advantage, "extra_environments", {}), {
  })
  ecs_back_advantage_environments_concat = merge(lookup(var.configuration_ecs_back_advantage, "extra_environments", {}), {
  })
}

# Create ECS and ALB backend hermes
module "nha_ecs_back_hermes" {
  source = "./modules/fargateECS&ALB2"

  layer    = "${var.layer_2}-back"
  stack_id = var.stack_id
  region   = var.aws_region

  ecs_fargate           = lookup(var.configuration_ecs_back_hermes, "ecs_fargate")
  certificate_arn       = aws_acm_certificate.hermes_certificate.arn
  listener_rule_fargate = lookup(var.configuration_ecs_back_hermes, "listener_rule_fargate")
  extra_environments    = local.ecs_back_hermes_environments_concat

  db_subnets_public  = module.nha_network.subnets_public
  db_subnets_private = module.nha_network.subnets_private
  vpc                = module.nha_network.vpc.id

  efs = {
    file_system_id  = module.nha_efs_back_hermes.efs_file_system_reference.id
    access_point_id = module.nha_efs_back_hermes.efs_access_point_reference.id
  }

}

# Create ECS and ALB wordpress advantage
module "nha_ecs_wordpress_advantage" {

  source = "./modules/fargateECS&ALB2"

  layer    = "${var.layer_2}-word"
  stack_id = var.stack_id
  region   = var.aws_region

  ecs_fargate           = lookup(var.configuration_ecs_wordpress_advantage, "ecs_fargate")
  certificate_arn       = aws_acm_certificate.nha_certificate_wordpress_advantage.arn
  listener_rule_fargate = lookup(var.configuration_ecs_wordpress_advantage, "listener_rule_fargate")
  extra_environments    = local.ecs_wordpress_advantage_environments_concat

  db_subnets_public  = module.nha_network.subnets_public
  db_subnets_private = module.nha_network.subnets_private
  vpc                = module.nha_network.vpc.id
}

# Create ECS and ALB backend advantage
module "nha_ecs_back" {
  source = "./modules/fargateECS&ALB2"

  layer    = "${var.layer}-back-advan"
  stack_id = var.stack_id
  region   = var.aws_region

  ecs_fargate           = lookup(var.configuration_ecs_back_advantage, "ecs_fargate")
  certificate_arn       = aws_acm_certificate.nha_certificate_backend_advantage.arn
  listener_rule_fargate = lookup(var.configuration_ecs_back_advantage, "listener_rule_fargate")
  extra_environments    = local.ecs_back_advantage_environments_concat

  db_subnets_public  = module.nha_network.subnets_public
  db_subnets_private = module.nha_network.subnets_private
  vpc                = module.nha_network.vpc.id
}
