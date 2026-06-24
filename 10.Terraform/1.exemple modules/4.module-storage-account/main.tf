# -----------------------------------------------------------------------------
# Storage Account
# Service de stockage objet Azure. Utilisé pour les blobs, fichiers,
# tables et queues. Ici configuré pour le stockage de blobs (tfstate, artefacts).
# -----------------------------------------------------------------------------
resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  # Désactiver l'accès public aux blobs par défaut — bonne pratique de sécurité
  allow_nested_items_to_be_public = false

  # Activer le versioning des blobs pour protéger le tfstate
  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Blob Containers
# Créés dynamiquement depuis la map var.containers.
# access_type = "private" : accès uniquement via clé ou identité Azure AD.
# -----------------------------------------------------------------------------
resource "azurerm_storage_container" "this" {
  for_each = var.containers

  name                  = each.key
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = each.value.access_type
}
