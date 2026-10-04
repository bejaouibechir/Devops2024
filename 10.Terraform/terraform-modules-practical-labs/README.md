# terraform-modules-practical-labs

Dossier d'exemples pour l'Atelier 8 — Publier des Modules Terraform.
Chaque lab contient un module autonome (provider `local`, sans ressource cloud)
dans `modules/<nom>/`, prêt à être déplacé à la racine d'un dépôt pour publication.

| Module | Rôle |
|---|---|
| `01-tags-standard` | Produit une map de tags standardisés |
| `02-naming-convention` | Génère des noms cohérents pour les ressources |
| `03-env-file` | Génère un fichier `.env` |
| `04-app-config` | Génère un fichier `app-config.yaml` via template |
| `05-docker-compose-generator` | Génère un `docker-compose.yml` |
| `06-backup-policy-config` | Génère une politique de sauvegarde YAML |
