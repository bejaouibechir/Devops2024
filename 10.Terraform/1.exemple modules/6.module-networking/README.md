# module-networking

## Introduction

Ce module crée le réseau de base d'une infrastructure Azure :
un **Virtual Network**, un ou plusieurs **Subnets**, et un **Network Security Group** avec ses règles associées.

C'est le premier module à déployer dans tout projet Azure — sans réseau, aucune VM ni service ne peut communiquer.

## Ce que le module crée

```
Azure Resource Group (existant)
└── Virtual Network
    ├── Subnet "default"   (ou plusieurs subnets via for_each)
    │   └── Association NSG
    └── Network Security Group
        ├── Règle SSH (port 22) — par défaut
        └── Règles supplémentaires — configurables
```

## Démarche

### 1. Créer le fichier de configuration

Dans le dossier `module-networking/`, créer un fichier `terraform.tfvars` :

```hcl
resource_group_name = "rg-demo-networking"
location            = "francecentral"
vnet_name           = "vnet-demo"
address_space       = ["10.0.0.0/16"]

subnets = {
  default = { address_prefix = "10.0.1.0/24" }
  backend = { address_prefix = "10.0.2.0/24" }
}

nsg_rules = {
  allow-ssh = {
    priority  = 100
    direction = "Inbound"
    access    = "Allow"
    protocol  = "Tcp"
    port      = "22"
  }
  allow-http = {
    priority  = 200
    direction = "Inbound"
    access    = "Allow"
    protocol  = "Tcp"
    port      = "80"
  }
}

tags = {
  environment = "dev"
  managed_by  = "terraform"
}
```

### 2. Créer le Resource Group

Ce module ne crée pas le Resource Group — il doit exister avant :

```bash
az group create --name rg-demo-networking --location francecentral
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
# Lister les VNets créés
az network vnet list --resource-group rg-demo-networking --output table

# Lister les subnets
az network vnet subnet list \
  --resource-group rg-demo-networking \
  --vnet-name vnet-demo \
  --output table

# Lister les règles NSG
az network nsg rule list \
  --resource-group rg-demo-networking \
  --nsg-name vnet-demo-nsg \
  --output table
```

### 5. Nettoyer

```bash
terraform destroy
az group delete --name rg-demo-networking --yes
```

## Variables

| Variable | Type | Requis | Description |
|---|---|---|---|
| `resource_group_name` | string | oui | Resource Group existant |
| `location` | string | oui | Région Azure |
| `vnet_name` | string | oui | Nom du VNet |
| `address_space` | list(string) | oui | Plage IP du VNet |
| `subnets` | map(object) | non | Subnets à créer |
| `nsg_rules` | map(object) | non | Règles NSG |
| `tags` | map(string) | non | Tags des ressources |

## Outputs

| Output | Description |
|---|---|
| `vnet_id` | ID du Virtual Network |
| `vnet_name` | Nom du Virtual Network |
| `subnet_ids` | Map `nom → ID` des subnets |
| `nsg_id` | ID du Network Security Group |
