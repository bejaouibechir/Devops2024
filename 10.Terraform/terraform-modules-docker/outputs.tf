# Statut du module d'installation.
output "docker_install_status" {
  value = module.docker_install.install_status
}

# Fichier témoin créé sur la machine distante.
output "docker_install_marker" {
  value = module.docker_install.marker_file
}

# Nom du conteneur.
output "container_name" {
  value = module.docker_container.container_name
}

# URL du conteneur accessible depuis la machine locale.
output "container_url" {
  value = module.docker_container.container_url
}
