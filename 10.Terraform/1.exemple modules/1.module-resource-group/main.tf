# -----------------------------------------------------------------------------
# Resource Group
# Conteneur logique Azure qui regroupe toutes les ressources d'un projet.
# C'est la première ressource à créer — tous les autres modules en dépendent.
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}
