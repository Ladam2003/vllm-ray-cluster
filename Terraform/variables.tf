# ------------------------------
# Felhő és projekt beállítások
# ------------------------------
variable "cloud_provider" {
  description = "Választott felhő: openstack, aws, azure, gcp, onprem"
  type        = string
  default     = "openstack"
}

variable "project_prefix" {
  description = "Projekt neve előtagként"
  type        = string
  default     = "myproject"
}

variable "user_name" {
  description = "Felhasználó neve, ami a resource-ok nevében szerepel"
  type        = string
  default     = "user"
}

# ------------------------------
# Compute / VM beállítások
# ------------------------------
variable "bastion_ip" {
  description = "Ha üres, dinamikus IP-t kérünk"
  type        = string
  default     = ""
}

variable "worker_count" {
  description = "Worker VM-ek száma"
  type        = number
  default     = 1
}

variable "image_name" {
  description = "VM image neve"
  type        = string
  default     = ""
}

variable "flavor_name" {
  description = "VM típus/flavor"
  type        = string
  default     = ""
}

variable "volume_size" {
  description = "Root volume mérete GB-ban"
  type        = number
  default     = 50
}

# ------------------------------
# Network
# ------------------------------
variable "private_network" {
  description = "Privát hálózat neve vagy ID"
  type        = string
  default     = ""
}

variable "external_network" {
  description = "Publikus hálózat neve vagy ID"
  type        = string
  default     = ""
}

# ------------------------------
# Security
# ------------------------------
variable "allowed_cidr" {
  description = "Engedélyezett CIDR a belső forgalomhoz"
  type        = string
  default     = "192.168.0.0/24"
}

variable "allowed_ports" {
  description = "Publikus portok a bastionhoz"
  type        = list(number)
  default     = [22, 8000]
}

# ------------------------------
# SSH
# ------------------------------
variable "keypair_name" {
  description = "SSH keypair neve"
  type        = string
  default     = "default_sshkey"
}
