resource "aws_ecr_repository" "ecr_repository" {
  name                 = "ecr-${var.ecr_repository.name}-${var.project}-${var.environment}"
  image_tag_mutability = var.ecr_repository.image_tag_mutability
  force_delete         = var.ecr_repository.force_delete

  dynamic "encryption_configuration" {
    for_each = var.ecr_repository.encryption_configuration != null ? [var.ecr_repository.encryption_configuration] : []
    content {
      encryption_type = encryption_configuration.value.encryption_type

      kms_key = try(encryption_configuration.value.kms_key, null)
    }
  }

  dynamic "image_scanning_configuration" {
    for_each = var.ecr_repository.image_scanning_configuration != null ? [var.ecr_repository.image_scanning_configuration] : []
    content {
      scan_on_push = image_scanning_configuration.value.scan_on_push
    }
  }

  tags = merge(var.tags, {
    Name        = "ecr-${var.ecr_repository.name}-${var.project}-${var.environment}"
    Environment = var.environment
    Source      = "Terraform"
  })
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repository.name

  policy = jsonencode(var.ecr_lifecycle_policy)
}
