output "key_vault_id" {
  value       = azurerm_key_vault.this.id
  description = "ID du Key Vault."
}

output "key_vault_uri" {
  value       = azurerm_key_vault.this.vault_uri
  description = "URI du Key Vault (ex: https://kv-demo.vault.azure.net/)."
}

output "secret_ids" {
  value       = { for k, v in azurerm_key_vault_secret.this : k => v.id }
  description = "Map nom → ID des secrets créés."
}
