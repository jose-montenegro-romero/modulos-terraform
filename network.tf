# Create network
module "nha_network" {
  source = "./modules/network"

  vpc_cidr        = var.vpc_cidr
  stack_id        = var.stack_id
  layer           = var.layer
  subnets_private = var.subnets_private
  subnets_public  = var.subnets_public
}
