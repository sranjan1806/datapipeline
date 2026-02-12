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

# EC2 variables
variable "ec2_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ec2_ami_id" {
  type     = string
  default  = null
  nullable = true
}

variable "ec2_os_family" {
  type    = string
  default = "amazon-linux-2023"

  validation {
    condition     = contains(["amazon-linux-2023", "ubuntu-22.04"], var.ec2_os_family)
    error_message = "ec2_os_family must be one of: amazon-linux-2023, ubuntu-22.04."
  }
}

variable "ec2_key_name" {
  type     = string
  default  = null
  nullable = true
}

variable "ec2_root_volume_type" {
  type    = string
  default = "gp3"
}

variable "ec2_root_volume_size_gb" {
  type    = number
  default = 25

  validation {
    condition     = var.ec2_root_volume_size_gb >= 20 && var.ec2_root_volume_size_gb <= 30
    error_message = "ec2_root_volume_size_gb must be between 20 and 30 GiB."
  }
}
