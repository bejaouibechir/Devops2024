output "vm_id" {
  value       = azurerm_linux_virtual_machine.this.id
  description = "ID de la Virtual Machine."
}

output "vm_name" {
  value       = azurerm_linux_virtual_machine.this.name
  description = "Nom de la Virtual Machine."
}

output "private_ip" {
  value       = azurerm_network_interface.this.private_ip_address
  description = "Adresse IP privée de la VM."
}

output "public_ip" {
  value       = var.create_public_ip ? azurerm_public_ip.this[0].ip_address : null
  description = "Adresse IP publique de la VM. Null si create_public_ip = false."
}

output "nic_id" {
  value       = azurerm_network_interface.this.id
  description = "ID de la Network Interface."
}
