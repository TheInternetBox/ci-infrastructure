terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.75.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
