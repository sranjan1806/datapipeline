module "vpc" {
  source     = "../modules/vpc"
  name       = var.name
  cidr_block = var.vpc_cidr
  az_count   = 2

  public_subnet_cidrs  = ["10.20.0.0/20", "10.20.16.0/20"]
  private_subnet_cidrs = ["10.20.32.0/20", "10.20.48.0/20"]
}

# module "s3" {
#   source = "../modules/s3"

#   # IMPORTANT: S3 bucket names must be globally unique.
#   # Add a short unique suffix (like your initials + random) once.
#   name = "${var.name}-${var.unique_suffix}"

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#     Project     = var.name
#   }
# }

# module "mwaa" {
#   source = "../modules/mwaa"

#   name               = var.name
#   unique_suffix      = var.unique_suffix
#   vpc_id             = module.vpc.vpc_id
#   private_subnet_ids = module.vpc.private_subnet_ids

#   raw_bucket_arn     = module.s3.raw_bucket_arn
#   curated_bucket_arn = module.s3.curated_bucket_arn

#   airflow_version       = var.airflow_version
#   environment_class     = var.mwaa_environment_class
#   webserver_access_mode = var.mwaa_webserver_access_mode

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#     Project     = var.name
#   }
# }
