output "aws_ecs_service" {
  value = aws_ecs_service.main
}

output "aws_ecr_repository" {
  value = module.ecr
}

output "lb_listener_reference" {
  value = aws_lb_listener.lb_listener
}