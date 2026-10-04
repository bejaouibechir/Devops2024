variable "project" {
  description = "Nom du projet (prefixe)"
  type        = string
}

variable "environment" {
  description = "Environnement (dev, staging, production...)"
  type        = string
}

variable "resource_type" {
  description = "Type de ressource (vm, sa, rg, vnet...)"
  type        = string
}

variable "instance" {
  description = "Numero ou identifiant d'instance"
  type        = string
  default     = "01"
}

variable "separator" {
  description = "Separateur entre les composants du nom"
  type        = string
  default     = "-"
}
