variable "layer" {
  description = "A unique identifier for the deployment"
  type        = string
}

variable "stack_id" {
  description = "A unique identifier for the environment"
  type        = string
}

variable "ecr_repository" {
  description = "Configuration for the ECR repository"
  type = object({
    name                 = string
    image_tag_mutability = optional(string)
    force_delete         = optional(bool)
    encryption_configuration = optional(
      object({
        encryption_type = string
        kms_key         = optional(string)
      })
    )
    image_scanning_configuration = optional(
      object({
        scan_on_push = bool
      })
    )
  })
}

variable "ecr_lifecycle_policy" {
  description = "Configuration ecr lifecycle policy"
  type = object({
    rules = list(any)
  })
  default = {
    rules = [
      {
        rulePriority = 1
        description  = "Keep only last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  }
}

variable "tags" {
  description = "A map of tags to assign to the repository"
  type        = map(string)
  default     = {}
}
