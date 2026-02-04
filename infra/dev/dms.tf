module "dms" {
  source = "../modules/dms"

  name               = var.name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  aurora_endpoint = module.aurora.endpoint
  aurora_db_name  = "appdb"

  replication_username = var.dms_username
  replication_password = var.dms_password

  raw_bucket_name = module.s3.raw_bucket_name

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = var.name
  }
}
