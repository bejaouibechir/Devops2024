output "config_path" {
  description = "Chemin du fichier app-config.yaml genere"
  value       = local_file.app_config.filename
}
