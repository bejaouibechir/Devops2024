variable "app_name" {
  description = "Nom de l'application"
  type        = string
}

variable "environment" {
  description = "Environnement de deploiement"
  type        = string
  default     = "dev"
}

variable "port" {
  description = "Port d'ecoute de l'application"
  type        = number
  default     = 8080
}

variable "settings" {
  description = "Parametres additionnels cle/valeur"
  type        = map(string)
  default     = {}
}

variable "output_path" {
  description = "Chemin du fichier app-config.yaml genere"
  type        = string
  default     = "app-config.yaml"
}
