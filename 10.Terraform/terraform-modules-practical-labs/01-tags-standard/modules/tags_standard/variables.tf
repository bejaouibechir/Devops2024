variable "project" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement (dev, staging, production...)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment doit valoir dev, staging ou production."
  }
}

variable "owner" {
  description = "Equipe ou personne responsable de la ressource"
  type        = string
}

variable "extra_tags" {
  description = "Tags supplementaires a fusionner avec les tags standards"
  type        = map(string)
  default     = {}
}
