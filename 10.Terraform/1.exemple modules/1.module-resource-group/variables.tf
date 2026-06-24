variable "name" {
  type        = string
  description = "Nom du Resource Group Azure."

  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 90
    error_message = "Le nom du Resource Group doit contenir entre 3 et 90 caractères."
  }
}

variable "location" {
  type        = string
  description = "Région Azure où créer le Resource Group (ex: francecentral, westeurope)."
}

variable "tags" {
  type        = map(string)
  description = "Tags appliqués au Resource Group."
  default     = {}
}
