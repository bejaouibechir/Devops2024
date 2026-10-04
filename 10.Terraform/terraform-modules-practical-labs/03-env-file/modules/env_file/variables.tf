variable "variables" {
  description = "Paires cle/valeur a ecrire dans le fichier .env"
  type        = map(string)
}

variable "output_path" {
  description = "Chemin du fichier .env genere"
  type        = string
  default     = ".env"
}
