# Module terraform-local-env-file

## Rôle

Génère un fichier `.env` à partir d'une map de variables.

## Utilisation

```hcl
module "env" {
  source  = "NAMESPACE/env-file/local"
  version = "~> 1.0"

  variables = {
    api_url = "https://api.example.com"
    db_host = "localhost"
  }
}
```

## Inputs

| Nom | Type | Défaut | Description |
|---|---|---|---|
| `variables` | map(string) | — | Paires clé/valeur du fichier |
| `output_path` | string | `.env` | Chemin de sortie |

## Outputs

| Nom | Description |
|---|---|
| `file_path` | Chemin du fichier généré |
| `content` | Contenu du fichier |
