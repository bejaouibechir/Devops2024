# Nom du conteneur Docker.
variable "container_name" {
  type        = string
  description = "Nom du conteneur Docker."
  default     = "nginx-module-demo"
}

# Image Docker à utiliser.
variable "image_name" {
  type        = string
  description = "Image Docker à télécharger."
  default     = "nginx:alpine"
}

# Port externe exposé sur la machine distante.
variable "external_port" {
  type        = number
  description = "Port externe exposé sur la machine distante."
  default     = 8080

  validation {
    condition     = var.external_port >= 1024 && var.external_port <= 65535
    error_message = "external_port doit être entre 1024 et 65535."
  }
}
