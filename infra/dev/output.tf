output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

# output "raw_bucket_name" {
#   value = module.s3.raw_bucket_name
# }

# output "curated_bucket_name" {
#   value = module.s3.curated_bucket_name
# }

# output "mwaa_environment_name" {
#   value = module.mwaa.environment_name
# }

# output "mwaa_webserver_url" {
#   value = module.mwaa.webserver_url
# }

# output "airflow_bucket_name" {
#   value = module.mwaa.airflow_bucket_name
# }

output "postgres_nodes_sg_id" {
  value = aws_security_group.postgres_nodes.id
}

output "pg_primary_private_ip" {
  value = module.ec2_writer.private_ip
}

output "pg_replica1_private_ip" {
  value = module.ec2_replica1.private_ip
}

output "pg_replica2_private_ip" {
  value = module.ec2_replica2.private_ip
}
