# Retourne le fichier témoin.
output "marker_file" {
  value = var.marker_file
}

# Retourne un statut logique.
output "install_status" {
  value = terraform_data.install.output
}
