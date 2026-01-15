# Create ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = replace("cluster-${var.name}-${var.project}-${var.environment}", "_", "-")

  tags = merge(var.tags, {
    Name        = "cluster-${var.name}-${var.project}-${var.environment}"
    Environment = var.environment
    Source      = "Terraform"
  })
}
