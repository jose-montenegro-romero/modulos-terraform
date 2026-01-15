# Ejemplo de uso

module "vpc_endpoints" {
  source = "./modules/gateway_endpoints"

  project = ""
  environment = ""

  vpc_id          = "vpc-123456789"
  route_table_ids = ["rtb-012345", "rtb-67890"]
  
  # Si solo quisieras S3, podrías pasar: ["s3"]
  endpoints       = ["s3", "dynamodb"] 

  tags = {
    Environment = "Production"
    Project     = "DataPipeline"
  }
}