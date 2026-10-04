# Module terraform-local-tags-standard

## Rôle

Ce module produit une map de tags standardisés à appliquer sur toutes les ressources.

## Utilisation

```hcl
module "tags" {
  source  = "NAMESPACE/tags-standard/local"
  version = "~> 1.0"

  project     = "mon-projet"
  environment = "production"
  owner       = "platform-team"
}
```

## Inputs

| Nom | Type | Défaut | Description |
|---|---|---|---|
| `project` | string | — | Nom du projet |
| `environment` | string | — | dev, staging ou production |
| `owner` | string | — | Responsable de la ressource |
| `extra_tags` | map(string) | `{}` | Tags additionnels |

## Outputs

| Nom | Description |
|---|---|
| `tags` | Map fusionnée des tags standards et supplémentaires |
