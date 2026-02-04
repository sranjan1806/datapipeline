module "vpc" {
  source     = "../modules/vpc"
  name       = var.name
  cidr_block = var.vpc_cidr
  az_count   = 2

  public_subnet_cidrs  = ["10.20.0.0/20", "10.20.16.0/20"]
  private_subnet_cidrs = ["10.20.32.0/20", "10.20.48.0/20"]
}

module "s3" {
  source = "../modules/s3"

  # IMPORTANT: S3 bucket names must be globally unique.
  # Add a short unique suffix (like your initials + random) once.
  name = "${var.name}-${var.unique_suffix}"

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = var.name
  }
}

module "aurora" {
  source = "../modules/aurora"

  name               = var.name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  db_name         = "appdb"
  master_username = "masteruser"
  master_password = var.db_master_password

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = var.name
  }
}
