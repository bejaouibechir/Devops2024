variable "resource_group_name" {
  type        = string
  description = "Nom du Resource Group Azure existant."
}

variable "location" {
  type        = string
  description = "Région Azure (ex: francecentral)."
}

variable "vm_name" {
  type        = string
  description = "Nom de la Virtual Machine."
}

variable "vm_size" {
  type        = string
  description = "Taille de la VM Azure (ex: Standard_B1s, Standard_B2s)."
  default     = "Standard_B1s"
}

variable "subnet_id" {
  type        = string
  description = "ID du subnet auquel attacher la VM."
}

variable "admin_username" {
  type        = string
  description = "Nom de l'utilisateur administrateur de la VM."
  default     = "adminuser"
}

variable "ssh_public_key" {
  type        = string
  description = "Contenu de la clé publique SSH (id_rsa.pub)."
}

variable "create_public_ip" {
  type        = bool
  description = "Créer une adresse IP publique pour la VM."
  default     = true
}

variable "os_disk_size_gb" {
  type        = number
  description = "Taille du disque OS en Go."
  default     = 30

  validation {
    condition     = var.os_disk_size_gb >= 30
    error_message = "La taille minimale du disque OS est 30 Go."
  }
}

variable "custom_data" {
  type        = string
  description = "Script cloud-init passé à la VM au démarrage (non encodé en base64)."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags appliqués à toutes les ressources du module."
  default     = {}
}
