# module-linux-vm

## Introduction

Ce module déploie une **machine virtuelle Linux (Ubuntu 22.04)** sur Azure avec son interface réseau et une adresse IP publique optionnelle. La VM est accessible en SSH via une paire de clés RSA.

C'est le module central du projet fil rouge — il crée les serveurs sur lesquels Ansible interviendra ensuite.

## Ce que le module crée

```
Azure Resource Group (existant)
└── Public IP (optionnelle, selon create_public_ip)
└── Network Interface
    └── Linux Virtual Machine (Ubuntu 22.04 LTS)
        ├── Authentification SSH par clé publique
        ├── Disque OS Standard_LRS
        └── cloud-init optionnel (custom_data)
```

## Prérequis

- Un subnet existant (utiliser `module-networking` ou créer manuellement)
- Une paire de clés SSH : `id_rsa` (privée) + `id_rsa.pub` (publique)

Générer une paire de clés si nécessaire :

```bash
ssh-keygen -t rsa -b 4096 -f ./id_rsa -N ""
```

## Démarche

### 1. Créer le fichier de configuration

```hcl
# terraform.tfvars
resource_group_name = "rg-demo-vm"
location            = "francecentral"
vm_name             = "vm-demo-web"
vm_size             = "Standard_B1s"
subnet_id           = "/subscriptions/<id>/resourceGroups/.../subnets/default"
admin_username      = "adminuser"
ssh_public_key      = "ssh-rsa AAAA... adminuser"
create_public_ip    = true

tags = {
  environment = "dev"
  managed_by  = "terraform"
}
```

Pour injecter la clé publique directement depuis le fichier :

```hcl
# Dans un main.tf qui appelle ce module
ssh_public_key = file("./id_rsa.pub")
```

### 2. Créer le Resource Group et le subnet

```bash
az group create --name rg-demo-vm --location francecentral
```

Si vous n'avez pas de subnet, déployer d'abord `module-networking` et récupérer l'output `subnet_ids["default"]`.

### 3. Exécuter Terraform

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

### 4. Se connecter à la VM

```bash
# Récupérer l'IP publique depuis les outputs
terraform output public_ip

# Connexion SSH
ssh -i ./id_rsa adminuser@<public_ip>
```

### 5. Nettoyer

```bash
terraform destroy
az group delete --name rg-demo-vm --yes
```

## Variables

| Variable | Type | Requis | Description |
|---|---|---|---|
| `resource_group_name` | string | oui | Resource Group existant |
| `location` | string | oui | Région Azure |
| `vm_name` | string | oui | Nom de la VM |
| `vm_size` | string | oui | Taille Azure (ex: `Standard_B1s`) |
| `subnet_id` | string | oui | ID du subnet où attacher la VM |
| `admin_username` | string | oui | Nom de l'utilisateur admin |
| `ssh_public_key` | string | oui | Contenu de la clé publique SSH |
| `create_public_ip` | bool | non | Créer une IP publique (défaut: `true`) |
| `os_disk_size_gb` | number | non | Taille du disque OS en Go (défaut: `30`) |
| `custom_data` | string | non | Script cloud-init (non encodé) |
| `tags` | map(string) | non | Tags des ressources |

## Outputs

| Output | Description |
|---|---|
| `vm_id` | ID de la Virtual Machine |
| `vm_name` | Nom de la VM |
| `private_ip` | IP privée de la VM |
| `public_ip` | IP publique (vide si `create_public_ip = false`) |
| `nic_id` | ID de la Network Interface |
