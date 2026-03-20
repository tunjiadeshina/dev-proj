# terraform/monitoring/outputs.tf
output "monitoring_vm_public_ip" {
  value = azurerm_public_ip.monitoring_ip.ip_address
}