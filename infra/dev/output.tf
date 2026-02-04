output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "raw_bucket_name" {
  value = module.s3.raw_bucket_name
}

output "curated_bucket_name" {
  value = module.s3.curated_bucket_name
}
