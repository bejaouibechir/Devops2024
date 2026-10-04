variable "service_name" {
  description = "Nom du service Docker"
  type        = string
}

variable "image" {
  description = "Image Docker (ex: nginx:latest)"
  type        = string
}

variable "ports" {
  description = "Liste des mappings de ports (ex: [\"8080:80\"])"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Variables d'environnement du conteneur"
  type        = map(string)
  default     = {}
}

variable "output_path" {
  description = "Chemin du fichier docker-compose.yml genere"
  type        = string
  default     = "docker-compose.yml"
}
