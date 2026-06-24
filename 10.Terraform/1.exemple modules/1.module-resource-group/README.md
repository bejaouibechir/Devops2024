# module-resource-group

## Introduction

Ce module crée un **Azure Resource Group** — le conteneur logique qui regroupe toutes les ressources d'un projet Azure. C'est la première ressource à créer avant tout déploiement : VNet, VMs, Storage, Key Vault, tout doit appartenir à un Resource Group.

Dans le projet fil rouge, ce module est le point de départ du Milestone 1. Tous les autres modules reçoivent son output `name` en entrée.

Ce README documente la démarche complète : publication du module dans le GitLab Terraform Registry, consommation depuis un projet, et exécution via GitLab CI/CD.

---

## Ce que le module crée

```
Azure Subscription
└── Resource Group
    ├── Nom    : configurable via variable
    ├── Région : configurable via variable
    └── Tags   : configurables via variable
```

---

## Fichiers du module

```
module-azure-rg/
├── main.tf        # ressource azurerm_resource_group
├── variables.tf   # name, location, tags
├── outputs.tf     # id, name, location
└── versions.tf    # provider azurerm ~> 3.110
```

---

## Étape 1 — Comprimer le module

Sur la machine Linux, depuis la racine du projet Git :

```bash
tar -czf /tmp/module-azure-rg.tar.gz -C module-azure-rg .
```

> `-C module-azure-rg .` comprime le **contenu** du dossier, pas le dossier lui-même. Les fichiers `.tf` seront à la racine du tarball.

---

## Étape 2 — Publier dans Operate → Terraform modules

Utiliser l'API GitLab avec un **Personal Access Token** (scope `api`) :

```bash
curl --fail \
     --header "PRIVATE-TOKEN: <votre_gitlab_token>" \
     --upload-file /tmp/module-azure-rg.tar.gz \
     "https://gitlab.com/api/v4/projects/<NAMESPACE>%2F<PROJECT>/packages/terraform/modules/azure-rg/azurerm/1.0.0/file"
```

Remplacer :

- `<votre_gitlab_token>` → Personal Access Token GitLab
- `<NAMESPACE>%2F<PROJECT>` → le namespace et le nom du projet séparés par `%2F` (encodage URL du slash `/`)

Exemple concret avec des valeurs fictives :

```bash
# Namespace GitLab  : terraform24888450
# Nom du projet     : terraform-modules
# Token GitLab      : glpat-xxxxxxxxxxxxxxxxxxxx
# Version publiée   : 1.0.0

curl --fail \
     --header "PRIVATE-TOKEN: glpat-xxxxxxxxxxxxxxxxxxxx" \
     --upload-file /tmp/module-azure-rg.tar.gz \
     "https://gitlab.com/api/v4/projects/terraform24888450%2Fterraform-modules/packages/terraform/modules/azure-rg/azurerm/1.0.0/file"
```

> `terraform24888450%2Fterraform-modules` est simplement `terraform24888450/terraform-modules` avec le `/` remplacé par `%2F` (encodage URL obligatoire dans ce contexte).

La réponse `201 Created` confirme la publication. Le module est alors visible dans **Operate → Terraform modules** sous le nom `azure-rg/azurerm v1.0.0`.

> Le nom du module (`azure-rg`) et le provider (`azurerm`) sont définis dans l'URL de l'API, pas dans les fichiers Terraform.

---

## Étape 3 — Créer les fichiers consommateurs

À la **racine du projet Git**, créer les fichiers suivants.

Ajouter le dossier source du module au `.gitignore` pour éviter de le versionner en double :

```bash
echo "module-azure-rg/" >> .gitignore
```

### versions.tf

```hcl
terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}

provider "azurerm" {
  features {}
}
```

### main.tf

```hcl
module "resource_group" {
  source  = "gitlab.com/<NAMESPACE>/azure-rg/azurerm"
  version = "1.0.0"

  name     = var.rg_name
  location = var.location
  tags     = var.tags
}
```

> Le namespace pourrait être le nom du compte comme vadimaentreprise ou le nom du groupe exemple terraform24888450

### variables.tf

```hcl
variable "rg_name" {
  type        = string
  description = "Nom du Resource Group à créer sur Azure."
}

variable "location" {
  type        = string
  description = "Région Azure."
  default     = "francecentral"
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

### terraform.tfvars

```hcl
rg_name  = "rg-fil-rouge-dev"
location = "francecentral"

tags = {
  environment = "dev"
  project     = "fil-rouge"
  managed_by  = "terraform"
  owner       = "bechir"
}
```

### outputs.tf

```hcl
output "resource_group_name" {
  value = module.resource_group.name
}

output "resource_group_location" {
  value = module.resource_group.location
}

output "resource_group_id" {
  value = module.resource_group.id
}
```

---

## Étape 4 — Configurer les variables GitLab CI/CD

Dans **Settings → CI/CD → Variables**, créer les 5 variables suivantes.

> ⚠️ Ne pas cocher **Protect variable** — les variables protégées ne sont disponibles que sur les branches protégées. Sans cela, le `terraform plan` se bloque indéfiniment sans message d'erreur.

| Variable              | Description                                | Masked |
| --------------------- | ------------------------------------------ | ------ |
| `ARM_CLIENT_ID`       | `appId` du Service Principal Azure         | ✅      |
| `ARM_CLIENT_SECRET`   | `password` du Service Principal Azure      | ✅      |
| `ARM_TENANT_ID`       | `tenant` du Service Principal Azure        | ✅      |
| `ARM_SUBSCRIPTION_ID` | ID de l'abonnement Azure                   | ✅      |
| `TF_TOKEN_gitlab_com` | Personal Access Token GitLab (scope `api`) | ✅      |

### Comment ces variables arrivent dans le pipeline sans apparaître dans le code ?

Ces variables ne sont présentes **ni dans le `.gitlab-ci.yml` ni dans les fichiers Terraform** — c'est voulu. GitLab les injecte automatiquement comme variables d'environnement Linux dans le conteneur du runner au moment de l'exécution du job :

```
GitLab Settings → CI/CD → Variables
        │
        └── GitLab injecte au lancement du job
                (comme des export Linux dans le conteneur)
                        │
                        └── Terraform les lit automatiquement
                                ARM_CLIENT_ID, ARM_CLIENT_SECRET,
                                ARM_TENANT_ID, ARM_SUBSCRIPTION_ID
                                → authentification Azure transparente
```

C'est l'équivalent de faire sur votre terminal :

```bash
export ARM_CLIENT_ID="xxx"
export ARM_CLIENT_SECRET="xxx"
export ARM_TENANT_ID="xxx"
export ARM_SUBSCRIPTION_ID="xxx"
terraform plan   # terraform lit ces variables sans configuration supplémentaire
```

Sauf que dans la CI, c'est GitLab qui exécute ces `export` à votre place, avant chaque job.

Pour vérifier que les variables sont bien disponibles dans un job, ajouter temporairement :

```yaml
script:
  - env | grep ARM   # affiche les noms des variables ARM présentes (valeurs masquées)
```

### Rôle exact de chaque variable dans le processus

Il existe deux catégories de variables qui servent à des moments différents :

**Variables d'authentification Azure (`ARM_*`)** — utilisées par le **provider azurerm**

Le bloc `provider "azurerm"` dans `versions.tf` ne contient aucune credential :

```hcl
provider "azurerm" {
  features {}
}
```

C'est intentionnel. Quand Terraform exécute `terraform plan` ou `terraform apply`, le provider azurerm cherche automatiquement dans l'environnement les variables `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID` et `ARM_SUBSCRIPTION_ID` pour s'authentifier auprès d'Azure. Si elles sont absentes, Terraform attend une authentification interactive — ce qui bloque le pipeline indéfiniment.

**Variable d'authentification GitLab (`TF_TOKEN_gitlab_com`)** — utilisée par **terraform init**

Lors du `terraform init`, Terraform doit télécharger le module depuis le GitLab Registry. Pour accéder à un registry privé, il a besoin d'un token. Terraform cherche automatiquement une variable d'environnement au format `TF_TOKEN_<hostname>` où les points sont remplacés par des underscores. Pour `gitlab.com`, cela donne `TF_TOKEN_gitlab_com`.

```
terraform init
    └── détecte source = "gitlab.com/..."
            └── cherche TF_TOKEN_gitlab_com dans l'environnement
                    └── s'authentifie et télécharge le module ✅
```

En résumé, aucune variable ne s'écrit dans le code — Terraform et le provider azurerm ont des conventions intégrées pour les lire depuis l'environnement système.

Créer le Service Principal si nécessaire :

```bash
az ad sp create-for-rbac \
  --name "sp-terraform-fil-rouge" \
  --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>
```

Récupérer le Subscription ID :

```bash
az account show --query id -o tsv
```

---

## Étape 5 — Écrire le `.gitlab-ci.yml`

```yaml
stages:
  - validate
  - plan
  - apply

image:
  name: hashicorp/terraform:1.9
  entrypoint: [""]        # obligatoire : sans cela GitLab exécute "terraform sh" et échoue

before_script:
  - terraform init        # télécharge le module depuis GitLab et le provider azurerm

validate:
  stage: validate
  script:
    - terraform validate

plan:
  stage: plan
  script:
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - tfplan

apply:
  stage: apply
  script:
    - terraform apply -auto-approve tfplan
  dependencies:
    - plan
  when: manual            # déclenchement manuel pour garder le contrôle
  only:
    - main
```

Pousser :

```bash
git add .gitlab-ci.yml versions.tf main.tf variables.tf terraform.tfvars outputs.tf .gitignore
git commit -m "ci: pipeline terraform validate plan apply"
git push origin main
```

---

## Étape 6 — Résultat attendu

Le pipeline s'exécute en 3 étapes :

```
validate ✅ → plan ✅ → apply (manuel) ✅
```

Après `apply`, vérifier sur Azure :

```bash
az group show --name rg-fil-rouge-dev --output table
```

```
Name              Location       Status
----------------  -------------  ---------
rg-fil-rouge-dev  francecentral  Succeeded
```

---

## Variables du module

| Variable   | Type        | Requis | Description                        |
| ---------- | ----------- | ------ | ---------------------------------- |
| `name`     | string      | oui    | Nom du Resource Group              |
| `location` | string      | oui    | Région Azure (ex: `francecentral`) |
| `tags`     | map(string) | non    | Tags appliqués au Resource Group   |

## Outputs du module

| Output     | Description                  |
| ---------- | ---------------------------- |
| `id`       | ID complet du Resource Group |
| `name`     | Nom du Resource Group        |
| `location` | Région du Resource Group     |

---

## Schéma récapitulatif

```
module-azure-rg/ (local)
    │
    ├── tar -czf → /tmp/module-azure-rg.tar.gz
    │
    └── curl → GitLab : Operate > Terraform modules (azure-rg/azurerm v1.0.0)
                    │
                    └── main.tf : source = "gitlab.com/<namespace>/azure-rg/azurerm"
                            │
                            └── GitLab CI pipeline
                                    ├── terraform init   (télécharge le module)
                                    ├── terraform validate
                                    ├── terraform plan
                                    └── terraform apply  → Azure Resource Group ✅
```
