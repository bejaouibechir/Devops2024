# module-key-vault

## Introduction

Ce module crée un **Azure Key Vault** et y stocke des **secrets** de façon sécurisée. Le Key Vault est le coffre-fort d'Azure — il centralise les mots de passe, tokens, chaînes de connexion et certificats, en dehors du code et des fichiers de configuration.

Dans un projet réel, on y stocke typiquement les credentials de base de données, les clés API, les tokens de service, ou les secrets injectés dans les VMs au démarrage.

## Ce que le module crée

```
Azure Resource Group (existant)
└── Key Vault
    ├── Access Policy → identité courante (lecture + écriture des secrets)
    ├── Secret "db-password"
    ├── Secret "api-key"
    └── Secret "..."  (configurables)
```

## Prérequis

Le module lit automatiquement l'identité Azure courante (via `data.azurerm_client_config`) pour créer la policy d'accès. Il faut donc être connecté avec `az login` ou via un Service Principal.

## Démarche

### 1. Créer le fichier de configuration

```hcl
# terraform.tfvars
resource_group_name = "rg-demo-keyvault"
location            = "francecentral"
key_vault_name      = "kv-demo-terraform-001"

secrets = {
  db-password = "MonMotDePasseBD!2024"
  api-key     = "sk-demo-1234567890abcdef"
}

tags = {
  environment = "dev"
  managed_by  = "terraform"
}
```

> Le nom du Key Vault doit être **globalement unique**, entre 3 et 24 caractères, lettres, chiffres et tirets uniquement.

### 2. Créer le Resource Group

```bash
az group create --name rg-demo-keyvault --location francecentral
```

### 3. Exécuter Terraform

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

### 4. Vérifier les secrets

```bash
# Lister les secrets (noms uniquement)
az keyvault secret list --vault-name kv-demo-terraform-001 --output table

# Lire la valeur d'un secret
az keyvault secret show \
  --vault-name kv-demo-terraform-001 \
  --name db-password \
  --query value \
  --output tsv
```

### 5. Lire un secret depuis un autre projet Terraform

```hcl
data "azurerm_key_vault" "shared" {
  name                = "kv-demo-terraform-001"
  resource_group_name = "rg-demo-keyvault"
}

data "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  key_vault_id = data.azurerm_key_vault.shared.id
}

# Utilisation
output "db_password" {
  value     = data.azurerm_key_vault_secret.db_password.value
  sensitive = true
}
```

### 6. Nettoyer

```bash
terraform destroy
az group delete --name rg-demo-keyvault --yes
```

> Par défaut, Azure garde le Key Vault en "soft delete" 90 jours. Pour supprimer définitivement :
> `az keyvault purge --name kv-demo-terraform-001`

## Variables

| Variable | Type | Requis | Description |
|---|---|---|---|
| `resource_group_name` | string | oui | Resource Group existant |
| `location` | string | oui | Région Azure |
| `key_vault_name` | string | oui | Nom unique global du Key Vault |
| `sku_name` | string | non | `standard` ou `premium` (défaut: `standard`) |
| `secrets` | map(string) | non | Map `nom → valeur` des secrets à créer |
| `tags` | map(string) | non | Tags des ressources |

## Outputs

| Output | Description |
|---|---|
| `key_vault_id` | ID du Key Vault |
| `key_vault_uri` | URI du Key Vault |
| `secret_ids` | Map `nom → ID` des secrets créés |
