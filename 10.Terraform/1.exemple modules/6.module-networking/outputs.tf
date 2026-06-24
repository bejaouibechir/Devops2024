output "vnet_id" {
  value       = azurerm_virtual_network.this.id
  description = "ID du Virtual Network."
}

output "vnet_name" {
  value       = azurerm_virtual_network.this.name
  description = "Nom du Virtual Network."
}

output "subnet_ids" {
  value       = { for k, v in azurerm_subnet.this : k => v.id }
  description = "Map nom → ID de chaque subnet créé."
}

output "nsg_id" {
  value       = azurerm_network_security_group.this.id
  description = "ID du Network Security Group."
}
