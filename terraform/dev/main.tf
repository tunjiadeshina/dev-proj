provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "belvadtfstate"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

module "vm" {
  source           = "../modules/vm"
  env              = "devops"
  location         = "Canada Central"
  vnet_cidr        = "10.0.0.0/16"
  subnet_cidr      = "10.0.1.0/24"
  vm_size          = "Standard_D2s_v3"
  ssh_public_key   = var.ssh_public_key
  ssh_allowed_cidr = var.ssh_allowed_cidr
  monitoring_cidr  = "10.3.1.0/24"
}
