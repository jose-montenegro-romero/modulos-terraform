# Define el proveedor AWS
provider "aws" {
  region = var.region
}

# Data source para obtener la identidad del llamante
data "aws_caller_identity" "current" {}
