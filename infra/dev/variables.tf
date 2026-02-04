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
