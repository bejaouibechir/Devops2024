# module-container-instance

## Introduction

Ce module déploie un **Azure Container Instance (ACI)** — un conteneur Docker qui tourne directement sur Azure, sans avoir à gérer des VMs ni un cluster Kubernetes. C'est la façon la plus rapide de faire tourner une image Docker sur Azure.

En quelques secondes après `terraform apply`, le conteneur est accessible via une IP publique. Idéal pour tester une image, déployer un outil interne, ou exposer une API légère.

## Ce que le module crée

```
Azure Resource Group (existant)
└── Container Group (ACI)
    ├── IP publique avec label DNS
    ├── Conteneur (image Docker configurable)
    │   ├── CPU et mémoire configurables
    │   ├── Variables d'environnement
    │   └── Port exposé
    └── URL d'accès : http://<dns_label>.<region>.azurecontainer.io
```

## Démarche

### 1. Créer le fichier de configuration

Exemple avec Nginx :

```hcl
# terraform.tfvars
resource_group_name    = "rg-demo-aci"
location               = "francecentral"
container_group_name   = "aci-demo-nginx"
container_name         = "nginx"
image                  = "nginx:latest"
cpu                    = 0.5
memory_gb              = 0.5
port                   = 80
dns_label              = "demo-nginx-terraform"

environment_variables = {
  ENVIRONMENT = "dev"
}

tags = {
  environment = "dev"
  managed_by  = "terraform"
}
```

Exemple avec une API Python (FastAPI) :

```hcl
image     = "tiangolo/uvicorn-gunicorn-fastapi:python3.11"
port      = 8000
dns_label = "demo-api-terraform"
```

### 2. Créer le Resource Group

```bash
az group create --name rg-demo-aci --location francecentral
```

### 3. Exécuter Terraform

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

### 4. Accéder au conteneur

```bash
# Récupérer l'URL depuis les outputs
terraform output container_url

# Tester dans le navigateur ou avec curl
curl http://demo-nginx-terraform.francecentral.azurecontainer.io
```

### 5. Voir les logs du conteneur

```bash
az container logs \
  --resource-group rg-demo-aci \
  --name aci-demo-nginx
```

### 6. Nettoyer

```bash
terraform destroy
az group delete --name rg-demo-aci --yes
```

## Variables

| Variable                | Type        | Requis | Description                                 |
| ----------------------- | ----------- | ------ | ------------------------------------------- |
| `resource_group_name`   | string      | oui    | Resource Group existant                     |
| `location`              | string      | oui    | Région Azure                                |
| `container_group_name`  | string      | oui    | Nom du Container Group                      |
| `container_name`        | string      | oui    | Nom du conteneur dans le groupe             |
| `image`                 | string      | oui    | Image Docker (ex: `nginx:latest`)           |
| `cpu`                   | number      | non    | CPU alloué (défaut: `0.5`)                  |
| `memory_gb`             | number      | non    | RAM en Go (défaut: `0.5`)                   |
| `port`                  | number      | non    | Port exposé (défaut: `80`)                  |
| `dns_label`             | string      | oui    | Label DNS (doit être unique dans la région) |
| `environment_variables` | map(string) | non    | Variables d'environnement du conteneur      |
| `tags`                  | map(string) | non    | Tags des ressources                         |

## Outputs

| Output               | Description                       |
| -------------------- | --------------------------------- |
| `container_group_id` | ID du Container Group             |
| `public_ip`          | Adresse IP publique du conteneur  |
| `container_url`      | URL complète d'accès au conteneur |
| `fqdn`               | FQDN du conteneur                 |
