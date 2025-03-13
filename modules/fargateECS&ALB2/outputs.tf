output "alb" {
  value = aws_alb.main
}

output "aws_security_group_alb" {
  value = aws_security_group.lb_fargate
}

output "aws_ecs_cluster" {
  value = aws_ecs_cluster.main
}

output "aws_ecs_service" {
  value = aws_ecs_service.main
}

output "aws_ecr_repository" {
  value = aws_ecr_repository.ecr
}
