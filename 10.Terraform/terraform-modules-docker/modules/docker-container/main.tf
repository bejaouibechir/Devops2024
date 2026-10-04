# Déclare le provider Docker attendu par ce module.
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6"
    }
  }
}

# Télécharge ou référence l'image Docker sur la machine distante.
resource "docker_image" "nginx" {
  name = var.image_name
}

# Crée le conteneur Nginx sur la machine distante.
resource "docker_container" "nginx" {
  name  = var.container_name
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.external_port
  }
}
