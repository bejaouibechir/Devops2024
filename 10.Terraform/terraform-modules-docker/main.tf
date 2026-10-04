# Déclare les providers nécessaires au projet racine.
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6"
    }
  }
}

# Provider Local.
provider "local" {}

# Provider Docker.
# Il se connecte au daemon Docker de la machine distante via SSH.
# Terraform ouvre un tunnel SSH vers le socket Docker distant.
provider "docker" {
  host = "ssh://${var.remote_user}@${var.remote_host}"

  ssh_opts = [
    "-i", var.ssh_private_key_path,
    "-o", "StrictHostKeyChecking=no",
  ]
}

# Module responsable de l'installation Docker sur la machine distante.
module "docker_install" {
  source = "./modules/docker-install"

  marker_file          = "docker-install.done"
  remote_host          = var.remote_host
  remote_user          = var.remote_user
  ssh_private_key_path = var.ssh_private_key_path
}

# Module responsable de la création du conteneur sur la machine distante.
module "docker_container" {
  source = "./modules/docker-container"

  container_name = var.container_name
  image_name     = var.image_name
  external_port  = var.external_port

  # Cette dépendance force Terraform à terminer l'installation
  # avant d'utiliser le provider Docker.
  depends_on = [
    module.docker_install
  ]
}
