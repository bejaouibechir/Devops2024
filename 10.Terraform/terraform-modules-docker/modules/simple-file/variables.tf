# Nom du fichier à créer.
variable "file_name" {
  type        = string
  description = "Nom du fichier local à créer."
}

# Contenu du fichier.
variable "file_content" {
  type        = string
  description = "Contenu du fichier local."
}
