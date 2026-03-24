variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

variable "ssh_allowed_cidr" {
  description = "CIDR range allowed to SSH (e.g. VPN or office IP)"
  type        = string
}
