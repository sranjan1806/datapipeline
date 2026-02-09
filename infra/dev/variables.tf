# shared variables for dev environment
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  type    = string
  default = "datapipeline-dev"
}

# VPC Variables
variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

# S3 Variables
variable "unique_suffix" {
  type        = string
  description = "Short unique suffix for S3 bucket names (e.g., shashi-01 or pr-2026)"
  default     = "shashi-01"
}

# Aurora Variables
variable "db_master_password" {
  type      = string
  sensitive = true
}

# DMS Variables
variable "dms_username" {
  type    = string
  default = "masteruser"
}

variable "dms_password" {
  type      = string
  default   = null
  nullable  = true
  sensitive = true
}

# MWAA variables
variable "airflow_version" {
  type    = string
  default = "2.8.1"
}

variable "mwaa_environment_class" {
  type    = string
  default = "mw1.small"
}

variable "mwaa_webserver_access_mode" {
  type    = string
  default = "PUBLIC_ONLY"
}
