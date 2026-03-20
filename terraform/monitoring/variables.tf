# terraform/monitoring/variables.tf
variable "location" {
  default = "canadacentral"
}

variable "admin_username" {
  default = "azureuser"
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

variable "dev_vm_ip" {
  type        = string
  description = "Dev VM public IP for prometheus scraping"
}

variable "staging_vm_ip" {
  type        = string
  description = "Staging VM public IP for prometheus scraping"
}

variable "prod_vm_ip" {
  type        = string
  description = "Prod VM public IP for prometheus scraping"
}