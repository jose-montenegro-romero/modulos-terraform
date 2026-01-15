module "my_interface_endpoints" {
  source     = "./modules/interface_endpoints"

  project = ""
  environment = ""

  vpc_id     = "vpc-0a1b2c3d"
  subnet_ids = ["subnet-123", "subnet-456"] # Típicamente subredes privadas
  
  # Lista de servicios que quieres habilitar
  endpoints = [
    "ssm",
    "ssmmessages",
    "ec2",
    "ec2messages",
    "logs" # Para CloudWatch Logs
  ]

  allowed_cidr_blocks = ["10.0.0.0/16"]
}