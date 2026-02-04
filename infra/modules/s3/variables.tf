variable "name" {
  type        = string
  description = "Prefix for bucket names (must be globally unique when combined with suffix)"
}

variable "tags" {
  type        = map(string)
  default     = {}
}
