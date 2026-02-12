variable "name" {
  description = "Name tag for instance"
  type        = string
}

variable "hostname" {
  description = "Hostname to configure in the guest OS"
  type        = string
}

variable "node_role" {
  description = "Logical role for this node (Writer, Replica1, Replica2)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet where the instance will be launched"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Security groups attached to the instance"
  type        = list(string)
}

variable "ami_id" {
  description = "Optional AMI ID. If null, AMI is selected by os_family."
  type        = string
  default     = null
  nullable    = true
}

variable "os_family" {
  description = "Base image family when ami_id is not provided"
  type        = string
  default     = "amazon-linux-2023"

  validation {
    condition     = contains(["amazon-linux-2023", "ubuntu-22.04"], var.os_family)
    error_message = "os_family must be one of: amazon-linux-2023, ubuntu-22.04."
  }
}

variable "key_name" {
  description = "Optional key pair name for SSH access"
  type        = string
  default     = null
  nullable    = true
}

variable "iam_instance_profile" {
  description = "Optional IAM instance profile name"
  type        = string
  default     = null
  nullable    = true
}

variable "root_volume_type" {
  description = "Root EBS volume type"
  type        = string
  default     = "gp3"
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 25

  validation {
    condition     = var.root_volume_size_gb >= 20 && var.root_volume_size_gb <= 30
    error_message = "root_volume_size_gb must be between 20 and 30 GiB."
  }
}

variable "tags" {
  description = "Extra tags"
  type        = map(string)
  default     = {}
}
