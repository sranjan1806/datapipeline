variable "name" {
  type = string
}

variable "unique_suffix" {
  type        = string
  description = "Short suffix to keep S3 bucket names globally unique."
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "raw_bucket_arn" {
  type = string
}

variable "curated_bucket_arn" {
  type = string
}

variable "airflow_version" {
  type    = string
  default = "2.8.1"
}

variable "environment_class" {
  type    = string
  default = "mw1.small"
}

variable "webserver_access_mode" {
  type    = string
  default = "PUBLIC_ONLY"
}

variable "min_workers" {
  type    = number
  default = 1
}

variable "max_workers" {
  type    = number
  default = 2
}

variable "schedulers" {
  type    = number
  default = 2
}

variable "tags" {
  type    = map(string)
  default = {}
}
