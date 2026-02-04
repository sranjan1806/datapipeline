output "dms_sg_id" {
  value = aws_security_group.dms.id
}

output "replication_instance_arn" {
  value = aws_dms_replication_instance.this.replication_instance_arn
}

output "task_arn" {
  value = aws_dms_replication_task.this.replication_task_arn
}

output "dms_s3_role_arn" {
  value = aws_iam_role.dms_s3.arn
}
