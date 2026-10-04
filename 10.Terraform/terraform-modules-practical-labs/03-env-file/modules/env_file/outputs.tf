output "file_path" {
  description = "Chemin du fichier .env genere"
  value       = local_file.env.filename
}

output "content" {
  description = "Contenu du fichier .env"
  value       = local_file.env.content
}
