# -----------------------------------------------------------------------------
# Virtual Network
# Réseau principal qui regroupe tous les subnets du projet.
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Subnets
# Créés dynamiquement depuis la map var.subnets.
# Chaque entrée de la map produit un subnet distinct.
# -----------------------------------------------------------------------------
resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.address_prefix]
}

# -----------------------------------------------------------------------------
# Network Security Group
# Contrôle le trafic entrant et sortant des subnets.
# Les règles sont injectées dynamiquement depuis var.nsg_rules.
# -----------------------------------------------------------------------------
resource "azurerm_network_security_group" "this" {
  name                = "${var.vnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = "*"
      destination_port_range     = security_rule.value.port
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

# -----------------------------------------------------------------------------
# Association NSG → Subnets
# Applique le même NSG à chaque subnet créé.
# -----------------------------------------------------------------------------
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this.id
}
