variable "name" {
  type        = string
  description = "Prefix for naming VPC resources"
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR block (e.g., 10.20.0.0/16)"
}

variable "az_count" {
  type        = number
  description = "How many AZs to use (2 recommended for MVP)"
  default     = 2
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs (length must match az_count)"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs (length must match az_count)"
}
