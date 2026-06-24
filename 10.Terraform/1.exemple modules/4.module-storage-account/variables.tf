variable "resource_group_name" {
  type        = string
  description = "Nom du Resource Group Azure existant."
}

variable "location" {
  type        = string
  description = "Région Azure (ex: francecentral)."
}

variable "storage_account_name" {
  type        = string
  description = "Nom du Storage Account — doit être globalement unique, 3-24 caractères, minuscules uniquement."

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Le nom du Storage Account doit contenir entre 3 et 24 caractères alphanumériques minuscules uniquement."
  }
}

variable "account_tier" {
  type        = string
  description = "Tier du Storage Account : Standard ou Premium."
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "account_tier doit être Standard ou Premium."
  }
}

variable "account_replication_type" {
  type        = string
  description = "Type de réplication : LRS (local), GRS (géo), ZRS (zone)."
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "account_replication_type doit être LRS, GRS, RAGRS, ZRS, GZRS ou RAGZRS."
  }
}

variable "containers" {
  type = map(object({
    access_type = string
  }))
  description = "Map des Blob Containers à créer. La clé devient le nom du container. access_type : private, blob, container."
  default = {
    tfstate = { access_type = "private" }
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags appliqués aux ressources."
  default     = {}
}
