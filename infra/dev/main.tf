module "vpc" {
  source     = "../modules/vpc"
  name       = var.name
  cidr_block = var.vpc_cidr
  az_count   = 2

  public_subnet_cidrs  = ["10.20.0.0/20", "10.20.16.0/20"]
  private_subnet_cidrs = ["10.20.32.0/20", "10.20.48.0/20"]
}
