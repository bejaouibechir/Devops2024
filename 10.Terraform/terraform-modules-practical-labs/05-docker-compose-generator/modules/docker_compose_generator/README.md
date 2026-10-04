# Module terraform-local-docker-compose-generator

## Rôle

Génère un fichier `docker-compose.yml` pour un service.

## Utilisation

```hcl
module "compose" {
  source  = "NAMESPACE/docker-compose-generator/local"
  version = "~> 1.0"

  service_name = "web"
  image        = "nginx:latest"
  ports        = ["8080:80"]

  environment = {
    NGINX_HOST = "localhost"
  }
}
```

## Inputs

| Nom | Type | Défaut | Description |
|---|---|---|---|
| `service_name` | string | — | Nom du service |
| `image` | string | — | Image Docker |
| `ports` | list(string) | `[]` | Mappings de ports |
| `environment` | map(string) | `{}` | Variables d'environnement |
| `output_path` | string | `docker-compose.yml` | Chemin de sortie |

## Outputs

| Nom | Description |
|---|---|
| `compose_path` | Chemin du fichier généré |
