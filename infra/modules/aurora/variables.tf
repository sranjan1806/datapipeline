variable "name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "master_username" {
  type    = string
  default = "masteruser"
}

variable "master_password" {
  type        = string
  description = "Set via tfvars or env. Do not hardcode."
  sensitive   = true
}

variable "engine_version" {
  type    = string
  default = "15.4" # you can change; keep modern
}

variable "instance_class" {
  type    = string
  default = "db.t4g.medium" # good MVP balance
}

variable "cluster_parameter_overrides" {
  type        = map(string)
  description = "Optional Aurora cluster parameter overrides merged on top of defaults."
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
