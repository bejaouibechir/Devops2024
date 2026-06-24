# -----------------------------------------------------------------------------
# Container Group — Azure Container Instance
# Un Container Group est l'unité de déploiement ACI.
# Il peut contenir un ou plusieurs conteneurs qui partagent le même réseau.
# Ici : un seul conteneur avec IP publique et label DNS.
# -----------------------------------------------------------------------------
resource "azurerm_container_group" "this" {
  name                = var.container_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = var.dns_label
  tags                = var.tags

  container {
    name   = var.container_name
    image  = var.image
    cpu    = var.cpu
    memory = var.memory_gb

    # Port exposé — doit correspondre au port sur lequel écoute l'application
    ports {
      port     = var.port
      protocol = "TCP"
    }

    # Variables d'environnement injectées dans le conteneur
    dynamic "environment_variables" {
      for_each = var.environment_variables
      content {
        name  = environment_variables.key
        value = environment_variables.value
      }
    }
  }
}
