output "storage_account_id" {
  value       = azurerm_storage_account.this.id
  description = "ID du Storage Account."
}

output "storage_account_name" {
  value       = azurerm_storage_account.this.name
  description = "Nom du Storage Account."
}

output "primary_blob_endpoint" {
  value       = azurerm_storage_account.this.primary_blob_endpoint
  description = "URL du endpoint Blob principal."
}

output "primary_access_key" {
  value       = azurerm_storage_account.this.primary_access_key
  description = "Clé d'accès principale du Storage Account."
  sensitive   = true
}

output "container_names" {
  value       = [for k, v in azurerm_storage_container.this : v.name]
  description = "Liste des noms de containers créés."
}
