variable "resource_group_name" {
  type        = string
  description = "Nom du Resource Group Azure existant."
}

variable "location" {
  type        = string
  description = "Région Azure (ex: francecentral, westeurope)."
}

variable "vnet_name" {
  type        = string
  description = "Nom du Virtual Network."
}

variable "address_space" {
  type        = list(string)
  description = "Plage d'adresses IP du VNet (ex: [\"10.0.0.0/16\"])."
}

variable "subnets" {
  type = map(object({
    address_prefix = string
  }))
  description = "Map des subnets à créer. La clé devient le nom du subnet."
  default = {
    default = { address_prefix = "10.0.1.0/24" }
  }
}

variable "nsg_rules" {
  type = map(object({
    priority  = number
    direction = string
    access    = string
    protocol  = string
    port      = string
  }))
  description = "Règles du Network Security Group. La clé devient le nom de la règle."
  default = {
    allow-ssh = {
      priority  = 100
      direction = "Inbound"
      access    = "Allow"
      protocol  = "Tcp"
      port      = "22"
    }
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags appliqués à toutes les ressources du module."
  default     = {}
}
