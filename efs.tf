# Create EFS-backend Hermes
module "nha_efs_back_hermes" {
  source = "./modules/efs"

  layer             = var.layer_2
  stack_id          = var.stack_id
  vpc               = module.nha_network.vpc.id
  db_subnets        = module.nha_network.subnets_private
  configuration_efs = var.configuration_efs_back_hermes
}
