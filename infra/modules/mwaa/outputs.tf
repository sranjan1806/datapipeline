output "environment_name" {
  value = aws_mwaa_environment.this.name
}

output "webserver_url" {
  value = aws_mwaa_environment.this.webserver_url
}

output "airflow_bucket_name" {
  value = aws_s3_bucket.airflow.bucket
}

output "execution_role_arn" {
  value = aws_iam_role.mwaa_execution.arn
}

output "security_group_id" {
  value = aws_security_group.mwaa.id
}
