# Region AWS
data "aws_region" "current" {}

# Data source para obtener la identidad del llamante
data "aws_caller_identity" "current" {}
