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
  default     = "0.0.0.0"
}

variable "stage_vm_ip" {
  type        = string
  description = "Stage VM public IP for prometheus scraping"
  default     = "0.0.0.0"
}

variable "prod_vm_ip" {
  type        = string
  description = "Prod VM public IP for prometheus scraping"
  default     = "0.0.0.0"
}