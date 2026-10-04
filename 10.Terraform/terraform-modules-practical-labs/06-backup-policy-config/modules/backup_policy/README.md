# Module terraform-local-backup-policy-config

## Rôle

Génère une politique de sauvegarde au format YAML.

## Utilisation

```hcl
module "backup" {
  source  = "NAMESPACE/backup-policy-config/local"
  version = "~> 1.0"

  policy_name    = "daily-db-backup"
  schedule       = "0 2 * * *"
  retention_days = 14
  targets        = ["/var/lib/postgresql", "/etc/app"]
}
```

## Inputs

| Nom | Type | Défaut | Description |
|---|---|---|---|
| `policy_name` | string | — | Nom de la politique |
| `schedule` | string | `"0 2 * * *"` | Expression cron |
| `retention_days` | number | `30` | Jours de rétention (> 0) |
| `targets` | list(string) | — | Cibles à sauvegarder |
| `output_path` | string | `backup-policy.yaml` | Chemin de sortie |

## Outputs

| Nom | Description |
|---|---|
| `policy_path` | Chemin du fichier généré |
