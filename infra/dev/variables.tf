variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  type    = string
  default = "datapipeline-dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "unique_suffix" {
  type        = string
  description = "Short unique suffix for S3 bucket names (e.g., shashi-01 or pr-2026)"
  default     = "shashi-01"
}
