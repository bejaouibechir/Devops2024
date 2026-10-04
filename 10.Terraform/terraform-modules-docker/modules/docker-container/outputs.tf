# Nom du conteneur créé.
output "container_name" {
  value = docker_container.nginx.name
}

# Image utilisée.
output "image_name" {
  value = var.image_name
}

# URL de test depuis la machine locale.
output "container_url" {
  value = "http://${docker_container.nginx.ports[0].ip}:${var.external_port}"
}
