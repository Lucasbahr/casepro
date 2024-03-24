terraform {
  backend "s3" {
    bucket = "bucket-terraform-tes"
    key    = "terraform/state.tfstate"  # Defina um valor válido para a chave do arquivo de estado
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  
}
