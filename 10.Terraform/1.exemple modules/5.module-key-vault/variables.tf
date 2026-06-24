variable "resource_group_name" {
  type        = string
  description = "Nom du Resource Group Azure existant."
}

variable "location" {
  type        = string
  description = "Région Azure (ex: francecentral)."
}

variable "key_vault_name" {
  type        = string
  description = "Nom du Key Vault — globalement unique, 3-24 caractères, lettres/chiffres/tirets."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.key_vault_name))
    error_message = "Le nom du Key Vault doit contenir entre 3 et 24 caractères (lettres, chiffres, tirets)."
  }
}

variable "sku_name" {
  type        = string
  description = "SKU du Key Vault : standard ou premium."
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name doit être standard ou premium."
  }
}

variable "secrets" {
  type        = map(string)
  description = "Map nom → valeur des secrets à stocker dans le Key Vault."
  default     = {}
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags appliqués aux ressources."
  default     = {}
}
