variable "resource_group_name" {
  type        = string
  description = "Nom du Resource Group Azure existant."
}

variable "location" {
  type        = string
  description = "Région Azure (ex: francecentral)."
}

variable "container_group_name" {
  type        = string
  description = "Nom du Container Group ACI."
}

variable "container_name" {
  type        = string
  description = "Nom du conteneur dans le groupe."
}

variable "image" {
  type        = string
  description = "Image Docker à déployer (ex: nginx:latest, mcr.microsoft.com/azuredocs/aci-helloworld)."
}

variable "cpu" {
  type        = number
  description = "Nombre de vCPU alloués au conteneur."
  default     = 0.5

  validation {
    condition     = var.cpu >= 0.5 && var.cpu <= 4
    error_message = "Le CPU doit être entre 0.5 et 4."
  }
}

variable "memory_gb" {
  type        = number
  description = "Mémoire RAM allouée au conteneur en Go."
  default     = 0.5

  validation {
    condition     = var.memory_gb >= 0.5 && var.memory_gb <= 16
    error_message = "La mémoire doit être entre 0.5 et 16 Go."
  }
}

variable "port" {
  type        = number
  description = "Port exposé par le conteneur."
  default     = 80
}

variable "dns_label" {
  type        = string
  description = "Label DNS unique dans la région. L'URL sera <dns_label>.<region>.azurecontainer.io."
}

variable "environment_variables" {
  type        = map(string)
  description = "Variables d'environnement injectées dans le conteneur."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags appliqués aux ressources."
  default     = {}
}
