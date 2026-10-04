# Nom du fichier témoin créé après installation (sur la machine distante).
variable "marker_file" {
  type        = string
  description = "Fichier témoin indiquant que le module docker-install a été exécuté."
  default     = "docker-install.done"
}

# Adresse IP ou nom DNS de la machine distante.
variable "remote_host" {
  type        = string
  description = "Adresse IP ou hostname de la machine distante."
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
