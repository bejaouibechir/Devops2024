# Adresse IP ou hostname de la machine distante.
variable "remote_host" {
  type        = string
  description = "Adresse IP ou hostname de la machine distante Ubuntu."
}

# Utilisateur SSH sur la machine distante.
variable "remote_user" {
  type        = string
  description = "Utilisateur SSH pour se connecter à la machine distante."
  default     = "ubuntu"
}

# Chemin local vers la clé privée SSH.
variable "ssh_private_key_path" {
  type        = string
  description = "Chemin vers la clé privée SSH sur la machine locale."
  default     = "~/.ssh/id_rsa"
}

# Nom du conteneur Docker.
variable "container_name" {
  type        = string
  description = "Nom du conteneur Nginx."
  default     = "nginx-module-demo"
}

# Image Docker utilisée.
variable "image_name" {
  type        = string
  description = "Image Docker utilisée."
  default     = "nginx:alpine"
}

# Port externe.
variable "external_port" {
  type        = number
  description = "Port HTTP exposé sur la machine distante."
  default     = 8080

  validation {
    condition     = var.external_port >= 1024 && var.external_port <= 65535
    error_message = "external_port doit être entre 1024 et 65535."
  }
}
