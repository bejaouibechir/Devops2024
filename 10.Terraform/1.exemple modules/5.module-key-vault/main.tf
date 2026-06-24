# -----------------------------------------------------------------------------
# Identité courante
# Récupère le tenant_id et l'object_id de l'identité qui exécute Terraform.
# Nécessaire pour créer la policy d'accès au Key Vault.
# -----------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

# -----------------------------------------------------------------------------
# Key Vault
# Coffre-fort centralisé pour les secrets, clés et certificats.
# Le soft_delete_retention_days protège contre les suppressions accidentelles.
# -----------------------------------------------------------------------------
resource "azurerm_key_vault" "this" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.sku_name
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Access Policy
# Accorde les droits de lecture et d'écriture des secrets à l'identité
# qui exécute Terraform (az login ou Service Principal).
# -----------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover"
  ]
}

# -----------------------------------------------------------------------------
# Secrets
# Créés dynamiquement depuis la map var.secrets.
# La clé devient le nom du secret, la valeur est le contenu stocké.
# depends_on garantit que la policy est active avant de créer les secrets.
# -----------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "this" {
  for_each = var.secrets

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [azurerm_key_vault_access_policy.current_user]
}
