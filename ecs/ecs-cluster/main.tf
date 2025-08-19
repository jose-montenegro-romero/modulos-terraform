# Create ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = replace("cluster-${var.name}-${var.layer}-${var.stack_id}", "_", "-")

  tags = merge(var.tags, {
    Name        = "cluster-${var.name}-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}
