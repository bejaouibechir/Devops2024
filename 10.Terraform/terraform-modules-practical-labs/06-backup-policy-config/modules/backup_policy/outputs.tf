output "policy_path" {
  description = "Chemin du fichier de politique de sauvegarde genere"
  value       = local_file.policy.filename
}
