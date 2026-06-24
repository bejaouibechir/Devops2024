output "container_group_id" {
  value       = azurerm_container_group.this.id
  description = "ID du Container Group."
}

output "public_ip" {
  value       = azurerm_container_group.this.ip_address
  description = "Adresse IP publique du Container Group."
}

output "fqdn" {
  value       = azurerm_container_group.this.fqdn
  description = "FQDN du conteneur (ex: demo-nginx.francecentral.azurecontainer.io)."
}

output "container_url" {
  value       = "http://${azurerm_container_group.this.fqdn}:${var.port}"
  description = "URL complète d'accès au conteneur."
}
