variable "policy_name" {
  description = "Nom de la politique de sauvegarde"
  type        = string
}

variable "schedule" {
  description = "Expression cron de la sauvegarde"
  type        = string
  default     = "0 2 * * *"
}

variable "retention_days" {
  description = "Nombre de jours de retention"
  type        = number
  default     = 30

  validation {
    condition     = var.retention_days > 0
    error_message = "retention_days doit etre superieur a 0."
  }
}

variable "targets" {
  description = "Liste des cibles a sauvegarder"
  type        = list(string)
}

variable "output_path" {
  description = "Chemin du fichier de politique genere"
  type        = string
  default     = "backup-policy.yaml"
}
