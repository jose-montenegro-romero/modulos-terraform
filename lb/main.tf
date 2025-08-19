#Create LB
module "sg_lb" {
  source = "../sg"


  layer    = var.layer
  stack_id = var.stack_id
  // configuration sg
  name    = lookup(var.configuration_lb, "name")
  vpc_id  = var.vpc_id
  ingress = lookup(var.configuration_lb, "ingress")
  egress  = lookup(var.configuration_lb, "egress")
  // TAGS
  tags = var.tags
}

resource "aws_lb" "lb" {
  name                                                         = replace(substr(replace("lb-${lookup(var.configuration_lb, "name")}-${var.stack_id}-${var.layer}", "_", "-"), 0, 31), "/-$/", "")
  internal                                                     = lookup(var.configuration_lb, "internal", false)
  subnets                                                      = var.subnets
  security_groups                                              = [module.sg_lb.sg_reference.id]
  enable_deletion_protection                                   = lookup(var.configuration_lb, "enable_deletion_protection", false)
  load_balancer_type                                           = lookup(var.configuration_lb, "load_balancer_type", "application")
  idle_timeout                                                 = lookup(var.configuration_lb, "idle_timeout", 60)
  enforce_security_group_inbound_rules_on_private_link_traffic = "on"

  tags = merge(var.tags, {
    Name        = replace("lb-${lookup(var.configuration_lb, "name")}-${var.layer}-${var.stack_id}", "_", "-")
    Environment = var.stack_id
    Source      = "Terraform"
    }
  )
}

