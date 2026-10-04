# Module terraform-local-naming-convention

## Rôle

Ce module génère des noms cohérents pour les ressources selon la convention
`projet-environnement-type-instance`.

## Utilisation

```hcl
module "naming" {
  source  = "NAMESPACE/naming-convention/local"
  version = "~> 1.0"

  project       = "andaluz"
  environment   = "production"
  resource_type = "vm"
  instance      = "01"
}

# => module.naming.name = "andaluz-production-vm-01"
```

## Inputs

| Nom | Type | Défaut | Description |
|---|---|---|---|
| `project` | string | — | Préfixe projet |
| `environment` | string | — | Environnement |
| `resource_type` | string | — | Type de ressource |
| `instance` | string | `"01"` | Identifiant d'instance |
| `separator` | string | `"-"` | Séparateur |

## Outputs

| Nom | Description |
|---|---|
| `name` | Nom complet de la ressource |
| `name_prefix` | Préfixe `projet-environnement` |
