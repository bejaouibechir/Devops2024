# -----------------------------------------------------------------------------
# Public IP (optionnelle)
# Créée uniquement si create_public_ip = true.
# Utilise le SKU Standard pour la compatibilité avec les LB et zones.
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "this" {
  count = var.create_public_ip ? 1 : 0

  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Network Interface
# Connecte la VM au subnet. Associe la Public IP si elle existe.
# -----------------------------------------------------------------------------
resource "azurerm_network_interface" "this" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.this[0].id : null
  }
}

# -----------------------------------------------------------------------------
# Linux Virtual Machine — Ubuntu 22.04 LTS
# Authentification uniquement par clé SSH (pas de mot de passe).
# cloud-init optionnel pour configurer la VM au premier démarrage.
# -----------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "this" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = var.tags

  network_interface_ids = [azurerm_network_interface.this.id]

  # Clé SSH publique — la clé privée reste sur la machine de l'opérateur
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  # Disque OS
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  # Image : Ubuntu 22.04 LTS Gen2
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # cloud-init encodé en base64 si fourni
  custom_data = var.custom_data != null ? base64encode(var.custom_data) : null

  # Désactiver l'authentification par mot de passe (bonne pratique)
  disable_password_authentication = true
}
