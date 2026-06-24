# module-storage-account

## Introduction

Ce module crée un **Azure Storage Account** avec un ou plusieurs **Blob Containers**. Le Storage Account est le service de stockage objet d'Azure — équivalent de S3 sur AWS.

Dans le projet fil rouge, ce module est utilisé pour héberger le **backend tfstate** de Terraform. Il peut aussi servir à stocker des artefacts, des backups, des fichiers de configuration, ou des logs.

## Ce que le module crée

```
Azure Resource Group (existant)
└── Storage Account
    ├── Container "tfstate"    (ou tout autre container configuré)
    ├── Container "backups"
    └── Container "artifacts"
```

## Démarche

### 1. Créer le fichier de configuration

```hcl
# terraform.tfvars
resource_group_name      = "rg-demo-storage"
location                 = "francecentral"
storage_account_name     = "stdemoterraform001"
account_tier             = "Standard"
account_replication_type = "LRS"

containers = {
  tfstate   = { access_type = "private" }
  backups   = { access_type = "private" }
  artifacts = { access_type = "private" }
}

tags = {
  environment = "dev"
  managed_by  = "terraform"
}
```

> Le nom du Storage Account doit être **globalement unique** dans Azure, en minuscules, entre 3 et 24 caractères, sans tirets.

### 2. Créer le Resource Group

```bash
az group create --name rg-demo-storage --location francecentral
```

### 3. Exécuter Terraform

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

### 4. Vérifier le résultat

```bash
# Lister les Storage Accounts
az storage account list --resource-group rg-demo-storage --output table

# Lister les containers
az storage container list \
  --account-name stdemoterraform001 \
  --auth-mode login \
  --output table
```

### 5. Utiliser ce Storage Account comme backend tfstate

Une fois déployé, configurer le backend dans un autre projet Terraform :

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-demo-storage"
    storage_account_name = "stdemoterraform001"
    container_name       = "tfstate"
    key                  = "mon-projet/terraform.tfstate"
  }
}
```

### 6. Nettoyer

```bash
terraform destroy
az group delete --name rg-demo-storage --yes
```

## Variables

| Variable | Type | Requis | Description |
|---|---|---|---|
| `resource_group_name` | string | oui | Resource Group existant |
| `location` | string | oui | Région Azure |
| `storage_account_name` | string | oui | Nom unique global du Storage Account |
| `account_tier` | string | non | `Standard` ou `Premium` (défaut: `Standard`) |
| `account_replication_type` | string | non | `LRS`, `GRS`, `ZRS` (défaut: `LRS`) |
| `containers` | map(object) | non | Containers Blob à créer |
| `tags` | map(string) | non | Tags des ressources |

## Outputs

| Output | Description |
|---|---|
| `storage_account_id` | ID du Storage Account |
| `storage_account_name` | Nom du Storage Account |
| `primary_blob_endpoint` | URL du endpoint Blob |
| `container_names` | Liste des containers créés |
