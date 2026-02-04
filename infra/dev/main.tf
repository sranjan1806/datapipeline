terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source     = "../modules/vpc"
  name       = var.name
  cidr_block = var.vpc_cidr
  az_count   = 2
}
