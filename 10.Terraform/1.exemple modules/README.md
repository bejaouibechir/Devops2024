# Exemples de modules Terraform — Azure

Collection de modules Terraform autonomes, orientés ressources Azure réelles.
Chaque module est indépendant et peut être testé seul.

## Modules disponibles

| Module | Ressources créées | Usage fil rouge |
|---|---|---|
| `module-resource-group` | Resource Group | ✅ M1 → M4 (point de départ) |
| `module-networking` | VNet, Subnet, NSG | ✅ M1 → M4 |
| `module-linux-vm` | VM Linux, NIC, Public IP | ✅ M2 → M4 |
| `module-storage-account` | Storage Account, Blob Containers | ✅ M3 (tfstate backend) |
| `module-key-vault` | Key Vault, Access Policy, Secrets | complémentaire |
| `module-container-instance` | Container Group Azure (Docker) | complémentaire |

## Prérequis communs

- Terraform >= 1.6
- Azure CLI installé et connecté : `az login`
- Un abonnement Azure actif

## Tester un module

Chaque module contient son propre `README.md` avec la démarche complète.
La séquence est toujours la même :

```bash
cd module-<nom>
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```
