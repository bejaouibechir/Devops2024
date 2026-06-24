output "id" {
  value       = azurerm_resource_group.this.id
  description = "ID complet du Resource Group."
}

output "name" {
  value       = azurerm_resource_group.this.name
  description = "Nom du Resource Group — à passer en entrée des autres modules."
}

output "location" {
  value       = azurerm_resource_group.this.location
  description = "Région du Resource Group — à passer en entrée des autres modules."
}
