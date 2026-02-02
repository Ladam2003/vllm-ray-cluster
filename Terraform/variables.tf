# ------------------------------
# Cloud & project settings
# ------------------------------
variable "cloud_provider" {
  description = "Choose platform: openstack, aws, azure, gcp, onprem"
  type        = string
  default     = "openstack"
}

variable "project_prefix" {
  description = "Projekt prefix name"
  type        = string
  default     = "myproject"
}

variable "user_name" {
  description = "User name, which will be used on resources name "
  type        = string
  default     = "user"
}

# ------------------------------
# Compute / VM setting
# ------------------------------
variable "bastion_ip" {
  description = "If its clear, we get dynamic IP"
  type        = string
  default     = ""
}

variable "worker_count" {
  description = "Worker VM counter"
  type        = number
  default     = 1
}

variable "image_name" {
  description = "VM image name"
  type        = string
  default     = ""
}

variable "flavor_name" {
  description = "VM flavor"
  type        = string
  default     = ""
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 50
}

# ------------------------------
# Network
# ------------------------------
variable "private_network" {
  description = "Private network name or ID"
  type        = string
  default     = ""
}

variable "external_network" {
  description = "Public network name or ID"
  type        = string
  default     = ""
}

# ------------------------------
# Security
# ------------------------------
variable "allowed_cidr" {
  description = "Allowed CIDR on inside routing"
  type        = string
  default     = "192.168.0.0/24"
}

variable "allowed_ports" {
  description = "Public ports for bastion server"
  type        = list(number)
  default     = [22, 8000]
}

# ------------------------------
# SSH
# ------------------------------
variable "keypair_name" {
  description = "SSH keypair name"
  type        = string
  default     = "default_sshkey"
}

