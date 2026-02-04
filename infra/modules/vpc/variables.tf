variable "name" {
  type        = string
  description = "Prefix for naming VPC resources"
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR block"
}

variable "az_count" {
  type        = number
  description = "How many AZs to use (2 recommended)"
  default     = 2
}
