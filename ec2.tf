# Create ec2 Bastion
module "ec2_nha" {
  source = "./modules/ec2"

  layer             = var.layer
  stack_id          = var.stack_id
  db_subnets_public = module.nha_network.subnets_public
  vpc               = module.nha_network.vpc.id
  ec2_definition    = var.configuration_ec2_bastion
}
