output "aws_ecs_service" {
  value = aws_ecs_service.main
}

output "aws_ecr_repository" {
  value = module.ecr
}

output "lb_dns" {
  value = module.lb_cluster[*].lb_reference.dns_name
}

output "ecs_nlb_env_vars" {
  value = local.ecs_nlb_env_vars
}