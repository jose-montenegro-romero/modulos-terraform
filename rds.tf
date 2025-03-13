module "rds_aurora_mysql_hermes" {

  source = "./modules/rds-aurora-v2"

  layer              = var.layer_2
  stack_id           = var.stack_id
  vpc                = module.nha_network.vpc.id
  db_subnets_private = concat(module.nha_network.subnets_private, module.nha_network.subnets_public)
  configuration_rds  = var.configuration_rds_aurora_mysql_hermes
}

module "rds_aurora_mysql_advantage" {

  source = "./modules/rds-aurora-v2"

  layer              = var.layer
  stack_id           = var.stack_id
  vpc                = module.nha_network.vpc.id
  db_subnets_private = module.nha_network.subnets_private
  configuration_rds  = var.configuration_rds_aurora_mysql_advantage
}

module "rds_aurora_mysql_back_advantage" {

  source = "./modules/rds-aurora-v2"

  layer              = var.layer
  stack_id           = var.stack_id
  vpc                = module.nha_network.vpc.id
  db_subnets_private = module.nha_network.subnets_private
  configuration_rds  = var.configuration_rds_aurora_mysql_back_advantage
}
