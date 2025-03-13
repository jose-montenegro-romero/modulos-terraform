terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.10.0"
    }
  }
}

provider "aws" {
  region     = "us-west-1"
  access_key = ""
  secret_key = ""
}

provider "aws" {
  alias      = "east"
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

terraform {
  backend "s3" {
    encrypt    = true
    bucket     = "nha-terraform-infra"
    key        = "terraform.tfstate"
    region     = "us-west-1"
    access_key = ""
    secret_key = ""
  }
}
