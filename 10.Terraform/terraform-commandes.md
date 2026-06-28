# Commandes Terraform — Arbre de référence

---

## A1. Premier tour — Commandes essentielles du quotidien

> Cycle de base pour déployer une infrastructure. Pour la liste complète des commandes et options, voir la section ci-dessous.

```
terraform
│
├── init                         # 1. Toujours en premier — initialise le projet
│   └── -upgrade                 #    Met à jour les providers si besoin
│
├── fmt -recursive               # 2. Formate le code avant de travailler
│
├── validate                     # 3. Vérifie la syntaxe
│
├── plan                         # 4. Prévisualise ce qui va changer
│   ├── -out=tfplan              #    Sauvegarde le plan pour l'appliquer ensuite
│   ├── -var-file=terraform.tfvars
│   └── -target=RESOURCE         #    Cibler une seule ressource si besoin
│
├── apply                        # 5. Applique les changements
│   ├── tfplan                   #    Applique le plan sauvegardé (recommandé)
│   └── -auto-approve            #    Sans prompt (CI/CD uniquement)
│
├── output                       # 6. Récupère les valeurs de sortie
│   └── -json                    #    Format machine-readable
│
├── state list                   # 7. Vérifie ce qui est géré dans le state
│
└── destroy                      # 8. Détruit tout (avec précaution)
    └── -auto-approve
```

---

## Vue complète des commandes

```
terraform
│
├── init                         # Initialise le répertoire de travail
│   ├── -upgrade                 # Met à jour les providers
│   ├── -reconfigure             # Ignore la config backend existante
│   ├── -backend=false           # Désactive le backend
│   └── -migrate-state           # Migre le state vers le nouveau backend
│
├── validate                     # Vérifie la syntaxe des fichiers .tf
│   └── -json                    # Sortie en JSON
│
├── fmt                          # Formate les fichiers .tf
│   ├── -check                   # Vérifie sans modifier
│   ├── -recursive               # Applique aux sous-dossiers
│   └── -diff                    # Affiche les différences
│
├── plan                         # Prévisualise les changements
│   ├── -out=FILE                # Sauvegarde le plan dans un fichier
│   ├── -var="key=value"         # Passe une variable
│   ├── -var-file=FILE           # Charge un fichier de variables
│   ├── -target=RESOURCE         # Cible une ressource spécifique
│   ├── -destroy                 # Plan de destruction
│   └── -refresh=false           # Ne pas synchroniser avec l'état réel
│
├── apply                        # Applique les changements
│   ├── FILE                     # Applique un plan sauvegardé
│   ├── -auto-approve            # Sans confirmation manuelle
│   ├── -var="key=value"
│   ├── -var-file=FILE
│   ├── -target=RESOURCE
│   └── -parallelism=N           # Nombre d'opérations parallèles (défaut: 10)
│
├── destroy                      # Détruit toutes les ressources
│   ├── -auto-approve
│   ├── -target=RESOURCE
│   └── -var="key=value"
│
├── output                       # Affiche les outputs
│   ├── NAME                     # Affiche un output précis
│   ├── -json                    # Sortie en JSON
│   └── -raw                     # Valeur brute (sans guillemets)
│
├── show                         # Affiche le state ou un plan
│   ├── FILE                     # Affiche un fichier de plan
│   └── -json                    # Sortie en JSON
│
├── state                        # Gestion du state
│   ├── list                     # Liste toutes les ressources
│   ├── show RESOURCE            # Détails d'une ressource
│   ├── mv SOURCE DEST           # Renomme/déplace une ressource
│   ├── rm RESOURCE              # Supprime du state (sans détruire)
│   └── pull                     # Affiche le state brut (JSON)
│
├── import                       # Importe une ressource existante dans le state
│   ├── RESOURCE ID
│   ├── -var="key=value"
│   └── -var-file=FILE
│
├── workspace                    # Gestion des workspaces
│   ├── list                     # Liste les workspaces
│   ├── new NAME                 # Crée un workspace
│   ├── select NAME              # Change de workspace
│   └── delete NAME              # Supprime un workspace
│
├── providers                    # Affiche les providers utilisés
│   ├── lock                     # Verrouille les versions providers
│   └── mirror DIR               # Copie les providers localement
│
├── graph                        # Génère un graphe de dépendances (format DOT)
│   └── -type=plan|apply|destroy
│
├── force-unlock LOCK_ID         # Déverrouille le state manuellement
│
├── login [HOSTNAME]             # Authentification à Terraform Cloud
├── logout [HOSTNAME]            # Déconnexion
│
└── version                      # Affiche la version de Terraform
```
