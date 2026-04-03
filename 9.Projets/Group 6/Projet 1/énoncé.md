# Projet DevOps — Système de Gestion de Flotte Véhicules

## Contexte

Une entreprise de revente de véhicules d'occasion souhaite moderniser son système de gestion interne. Elle vous confie la conception et le déploiement complet d'une application web permettant de gérer sa **flotte de véhicules**, ses **acheteurs** et ses **sites de vente**.

Votre mission couvre l'ensemble du cycle DevOps : développement, conteneurisation, intégration continue, orchestration et supervision.

---

## Objectifs pédagogiques

À l'issue de ce projet, vous serez capables de :

- Concevoir une API REST multi-entités avec **.NET 8 Web API** et **Entity Framework Core**
- Développer une interface web réactive avec **Vue 3** (mode CDN, sans build)
- Conteneuriser trois services distincts et les interconnecter via un **réseau Docker**
- Orchestrer l'environnement local avec **Docker Compose**
- Mettre en place un pipeline **GitLab CI/CD** automatisant build et déploiement
- Déployer l'application sur **Kubernetes** avec gestion de la persistance des données
- *(Bonus)* Superviser la base de données avec **Prometheus + Grafana**

---

## Architecture applicative

L'application repose sur trois couches :

```
┌─────────────────────────────────────────────────────────────┐
│                     Couche Présentation                      │
│         Vue 3 (CDN) · Nginx · Interface CRUD véhicules       │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTP / REST JSON
┌──────────────────────────▼──────────────────────────────────┐
│                      Couche Métier                           │
│         .NET 8 Web API · Entity Framework Core               │
│         Entités : Vehicule · Acheteur · SiteDeVente          │
└──────────────────────────┬──────────────────────────────────┘
                           │ TCP 1433
┌──────────────────────────▼──────────────────────────────────┐
│                    Couche Données                            │
│         SQL Server Express 2022 · init.sql                   │
│         Base : FlotteDB · 3 tables relationnelles            │
└─────────────────────────────────────────────────────────────┘
```

Les trois services communiquent via un **réseau Docker dédié** (`flotte-network`).

---

## Modèle de données

### Relations

```
SiteDeVente (1) ──< Vehicule >── (1) Acheteur
```

Un véhicule est associé à un site de vente et peut être assigné à un acheteur.

### Table `SitesDeVente`

| Colonne     | Type          | Contrainte   |
| ----------- | ------------- | ------------ |
| Id          | INT           | PK, IDENTITY |
| Nom         | NVARCHAR(200) | NOT NULL     |
| Ville       | NVARCHAR(100) | NOT NULL     |
| Adresse     | NVARCHAR(300) |              |
| Responsable | NVARCHAR(200) |              |

### Table `Acheteurs`

| Colonne   | Type          | Contrainte   |
| --------- | ------------- | ------------ |
| Id        | INT           | PK, IDENTITY |
| Nom       | NVARCHAR(200) | NOT NULL     |
| Prenom    | NVARCHAR(200) | NOT NULL     |
| Email     | NVARCHAR(200) | UNIQUE       |
| Telephone | NVARCHAR(20)  |              |

### Table `Vehicules`

| Colonne       | Type          | Contrainte                  |
| ------------- | ------------- | --------------------------- |
| Id            | INT           | PK, IDENTITY                |
| Marque        | NVARCHAR(100) | NOT NULL                    |
| Modele        | NVARCHAR(100) | NOT NULL                    |
| Annee         | INT           | NOT NULL                    |
| Kilometrage   | INT           | NOT NULL                    |
| Prix          | DECIMAL(10,2) | NOT NULL                    |
| Statut        | NVARCHAR(50)  | Disponible / Vendu          |
| SiteDeVenteId | INT           | FK → SitesDeVente(Id)       |
| AcheteurId    | INT           | FK → Acheteurs(Id), NULL OK |

---

## Structure du projet

```
flotte-vehicules/
├── backend/
│   ├── FlotteAPI/
│   │   ├── Controllers/
│   │   │   ├── VehiculesController.cs
│   │   │   ├── AcheteursController.cs
│   │   │   └── SitesDeVenteController.cs
│   │   ├── Models/
│   │   │   ├── Vehicule.cs
│   │   │   ├── Acheteur.cs
│   │   │   └── SiteDeVente.cs
│   │   ├── Data/
│   │   │   └── FlotteDbContext.cs
│   │   ├── appsettings.json
│   │   └── Program.cs
│   └── Dockerfile
├── frontend/
│   ├── index.html
│   ├── app.js
│   ├── style.css
│   └── Dockerfile
├── database/
│   ├── init.sql
│   └── Dockerfile
├── docker-compose.yml
├── .gitlab-ci.yml
└── k8s/
    ├── namespace.yaml
    ├── sqlserver-secret.yaml
    ├── sqlserver-statefulset.yaml
    ├── sqlserver-service.yaml
    ├── backend-deployment.yaml
    ├── backend-service.yaml
    ├── frontend-deployment.yaml
    ├── frontend-service.yaml
    └── bonus/
        ├── prometheus-config.yaml
        └── grafana-deployment.yaml
```

---

## Schéma DevOps

```
Developer
    │
    ▼
 Git Push
    │
    ▼
 GitLab Repository
    │
    ▼
 GitLab CI/CD (.gitlab-ci.yml)
    │
    ├── Stage: build
    │     ├── build:frontend   → docker build → push registry
    │     ├── build:backend    → docker build → push registry
    │     └── build:database   → docker build → push registry
    │
    └── Stage: deploy  (3 jobs parallèles)
          ├── deploy:frontend  → Nginx container (port 80)
          ├── deploy:backend   → .NET container (port 5000)
          └── deploy:database  → SQL Server container (port 1433)
                                    │
                               [flotte-network]
                         (les 3 containers s'y connectent)
```

---

## Partie 1 — Base de données SQL Server

### `database/init.sql`

Script SQL Server (T-SQL) à exécuter au démarrage du container pour :

- Créer la base `FlotteDB`
- Créer les trois tables avec les contraintes de clés étrangères
- Insérer un jeu de données de test (3 sites, 5 acheteurs, 10 véhicules)

> **Note** : SQL Server Express 2022 est disponible gratuitement via l'image Docker officielle `mcr.microsoft.com/mssql/server:2022-latest`. Elle requiert au minimum **2 Go de RAM** sur la machine hôte.

### `database/Dockerfile`

Basé sur l'image officielle SQL Server, avec injection du script `init.sql` via un entrypoint personnalisé.

---

## Partie 2 — Backend .NET 8 Web API

### Stack

- .NET 8 Web API
- Entity Framework Core 8 (provider : `Microsoft.EntityFrameworkCore.SqlServer`)
- Swagger / OpenAPI activé en développement

### Endpoints attendus (par entité)

| Méthode | Route                  | Action                    |
| ------- | ---------------------- | ------------------------- |
| GET     | /api/vehicules         | Lister tous les véhicules |
| GET     | /api/vehicules/{id}    | Détail d'un véhicule      |
| POST    | /api/vehicules         | Créer un véhicule         |
| PUT     | /api/vehicules/{id}    | Modifier un véhicule      |
| DELETE  | /api/vehicules/{id}    | Supprimer un véhicule     |
| GET     | /api/acheteurs         | Lister les acheteurs      |
| POST    | /api/acheteurs         | Créer un acheteur         |
| PUT     | /api/acheteurs/{id}    | Modifier un acheteur      |
| DELETE  | /api/acheteurs/{id}    | Supprimer un acheteur     |
| GET     | /api/sitesdevente      | Lister les sites de vente |
| POST    | /api/sitesdevente      | Créer un site             |
| PUT     | /api/sitesdevente/{id} | Modifier un site          |
| DELETE  | /api/sitesdevente/{id} | Supprimer un site         |

### Chaîne de connexion (`appsettings.json`)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=db,1433;Database=FlotteDB;User Id=sa;Password=${SA_PASSWORD};TrustServerCertificate=True"
  }
}
```

L'host `db` correspond au nom du service SQL Server dans le réseau Docker.

### `backend/Dockerfile`

Build multi-stage recommandé :

1. Stage `build` : image `mcr.microsoft.com/dotnet/sdk:8.0` → restore + publish
2. Stage `runtime` : image `mcr.microsoft.com/dotnet/aspnet:8.0` → copie les binaires

---

## Partie 3 — Frontend Vue 3 (CDN)

### Stack

- Vue 3 chargé via CDN (pas de build, pas de Node.js requis)
- Axios pour les appels API
- Nginx comme serveur web statique

### Interface attendue

L'application doit proposer trois vues navigables :

1. **Véhicules** — tableau de la flotte avec filtres (marque, statut), ajout / édition / suppression, changement de statut (Disponible → Vendu)
2. **Acheteurs** — liste des acheteurs avec formulaire CRUD
3. **Sites de vente** — liste des sites avec formulaire CRUD

### `frontend/Dockerfile`

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
```

---

## Partie 4 — Docker Compose

### `docker-compose.yml`

Trois services interconnectés via `flotte-network` :

```yaml
# Structure attendue
services:
  db:          # SQL Server Express 2022
  backend:     # .NET 8 API — depends_on: db
  frontend:    # Vue 3 / Nginx — depends_on: backend

networks:
  flotte-network:
    driver: bridge
```

**Ports exposés sur l'hôte :**

- Frontend : `8080:80`
- Backend : `5000:5000`
- SQL Server : `1433:1433`

**Variables d'environnement** : le mot de passe SA de SQL Server doit être injecté via variable d'environnement (ne jamais le hardcoder dans le Dockerfile).

### Test de l'orchestration

```bash
docker compose up -d --build
docker compose ps          # vérifier que les 3 containers sont "running"
docker compose logs backend --follow
curl http://localhost:5000/api/vehicules   # doit retourner []
```

---

## Partie 5 — GitLab CI/CD

### `.gitlab-ci.yml`

Pipeline en deux stages :

**Stage `build`** (3 jobs parallèles) :

- Construit l'image Docker de chaque service
- La pousse dans le **GitLab Container Registry** du projet

**Stage `deploy`** (3 jobs parallèles) :

- Se connecte à `sv2` via SSH
- Lance `docker compose up -d` pour le service concerné

```yaml
# Variables à définir dans GitLab > Settings > CI/CD > Variables
# SA_PASSWORD   : mot de passe SQL Server
# SSH_PRIVATE_KEY : clé SSH pour sv2
# SV2_HOST      : adresse IP de sv2
```

---

## Partie 6 — Kubernetes

### Manifestes à créer

#### SQL Server — StatefulSet

```
k8s/sqlserver-statefulset.yaml
```

- `StatefulSet` avec 1 réplica
- `PersistentVolumeClaim` de 5Gi pour `/var/opt/mssql`
- Secret Kubernetes pour le mot de passe SA (`sqlserver-secret.yaml`)
- Service de type `ClusterIP` sur port 1433

#### Backend — Deployment

```
k8s/backend-deployment.yaml
```

- `Deployment` avec 2 réplicas
- Variable `ConnectionStrings__DefaultConnection` injectée via ConfigMap ou Secret
- Service de type `ClusterIP` sur port 5000

#### Frontend — Deployment

```
k8s/frontend-deployment.yaml
```

- `Deployment` avec 2 réplicas
- Service de type `LoadBalancer` (ou `NodePort` en local) sur port 80

### Commandes de validation

```bash
kubectl apply -f k8s/
kubectl get pods -n flotte
kubectl get svc -n flotte
kubectl exec -it <pod-sqlserver> -- /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -Q "SELECT name FROM sys.databases"
```

---

## Partie 7 (Bonus) — Supervision avec Prometheus & Grafana

### Objectif

Mettre en place un monitoring du StatefulSet SQL Server pour visualiser :

- Connexions actives
- Utilisation CPU / mémoire du container
- Latence des requêtes

### Stack

- **`sql_exporter`** (FreeTDS / Prometheus SQL Exporter) : expose les métriques SQL Server au format Prometheus
- **Prometheus** : scrape les métriques toutes les 15s
- **Grafana** : tableau de bord préconstruit pour SQL Server

### Architecture de supervision

```
SQL Server Pod
     │
     ▼
sql_exporter (sidecar ou pod séparé)  :9399
     │
     ▼
Prometheus  :9090
     │
     ▼
Grafana  :3000
```

---

## Critères d'évaluation

| Critère                                           | Points        |
| ------------------------------------------------- | ------------- |
| API .NET — 3 contrôleurs CRUD fonctionnels        | 20            |
| Frontend Vue 3 — 3 vues avec appels API           | 15            |
| SQL Server — init.sql avec données de test        | 10            |
| Docker — 3 containers interconnectés (réseau)     | 15            |
| Docker Compose — orchestration complète           | 10            |
| GitLab CI/CD — pipeline build + deploy            | 20            |
| Kubernetes — StatefulSet + Deployments + Services | 10            |
| **Bonus** — Prometheus + Grafana                  | +10           |
| **Total**                                         | **100 (+10)** |

---

## Livrables attendus

1. Dépôt GitLab contenant l'ensemble du code source et des manifestes
2. Pipeline GitLab CI/CD fonctionnel (captures d'écran des stages)
3. `docker compose up` fonctionnel avec les 3 services `healthy`
4. Cluster Kubernetes déployé et accessible
5. *(Bonus)* Dashboard Grafana avec au moins 3 métriques SQL Server affichées

---

## Ressources utiles

- [Image Docker SQL Server officielle](https://hub.docker.com/_/microsoft-mssql-server)
- [Vue 3 via CDN](https://vuejs.org/guide/quick-start.html#using-vue-from-cdn)
- [Entity Framework Core — SQL Server](https://learn.microsoft.com/en-us/ef/core/providers/sql-server/)
- [Kubernetes StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Prometheus sql_exporter](https://github.com/burningalchemist/sql_exporter)
