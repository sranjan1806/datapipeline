variable "name" { type = string }

variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }

variable "aurora_endpoint" { type = string }
variable "aurora_port" {
  type    = number
  default = 5432
}
variable "aurora_db_name" { type = string }

variable "replication_username" {
  type        = string
  description = "DMS source DB user"
  default     = "dms_user"
}

variable "replication_password" {
  type      = string
  sensitive = true
}

variable "raw_bucket_name" { type = string }

variable "start_replication_task" {
  type        = bool
  description = "Whether to start the DMS replication task after creation."
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
