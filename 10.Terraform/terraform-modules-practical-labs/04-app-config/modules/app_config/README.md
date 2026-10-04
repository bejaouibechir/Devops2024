# Module terraform-local-app-config

## Rôle

Génère un fichier `app-config.yaml` à partir d'un template.

## Utilisation

```hcl
module "app_config" {
  source  = "NAMESPACE/app-config/local"
  version = "~> 1.0"

  app_name    = "andaluz-api"
  environment = "production"
  port        = 3000

  settings = {
    log_level = "info"
    timeout   = "30"
  }
}
```

## Inputs

| Nom | Type | Défaut | Description |
|---|---|---|---|
| `app_name` | string | — | Nom de l'application |
| `environment` | string | `"dev"` | Environnement |
| `port` | number | `8080` | Port d'écoute |
| `settings` | map(string) | `{}` | Paramètres additionnels |
| `output_path` | string | `app-config.yaml` | Chemin de sortie |

## Outputs

| Nom | Description |
|---|---|
| `config_path` | Chemin du fichier généré |
