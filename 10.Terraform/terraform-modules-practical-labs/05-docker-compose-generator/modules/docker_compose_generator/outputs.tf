output "compose_path" {
  description = "Chemin du fichier docker-compose.yml genere"
  value       = local_file.compose.filename
}
