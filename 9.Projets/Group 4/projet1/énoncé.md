# Énoncé de Projet — Déploiement d'une Application de Gestion des Employés

## Contexte

Vous êtes chargés de conteneuriser et d'automatiser le déploiement d'une application web de **gestion des employés**. L'application est composée d'un frontend statique, d'une API REST en Python Flask et d'une base de données PostgreSQL.

L'objectif est de maîtriser progressivement les techniques DevOps : de la conteneurisation manuelle jusqu'au déploiement continu via GitLab CI/CD avec stratégie **Blue/Green**.

---

## Architecture de l'application

```
Navigateur
    │  HTTP
    ▼
Frontend (HTML/CSS/JS + Nginx)  ── /api/ ──►  Backend Flask (API REST)
                                                      │
                                                      ▼
                                              PostgreSQL (base de données)
```

**Fonctionnalités :**
- Afficher / filtrer la liste des employés par département
- Ajouter, modifier, supprimer un employé
- Endpoint `GET /health` sur le backend (utilisé par le pipeline CI)

---

## Structure du projet

```
employee-app/
├── backend/
│   ├── app.py               ← API REST Flask (CRUD + /health)
│   ├── requirements.txt
│   ├── Dockerfile
│   └── tests/
│       └── test_app.py
├── frontend/
│   ├── index.html
│   ├── style.css
│   ├── app.js
│   ├── nginx.conf           ← proxy /api/ vers le service "backend"
│   └── Dockerfile
├── db/
│   └── init.sql             ← Création table + données de test
├── nginx/
│   └── nginx-bluegreen.conf.tpl  ← Template reverse proxy Blue/Green
├── docker-compose.yml
├── docker-compose.blue.yml  ← Environnement Blue (port 8080)
├── docker-compose.green.yml ← Environnement Green (port 8081)
├── .env                     ← Variables locales (non commité)
├── cleanup.sh               ← Nettoyage environnement Docker
└── .gitlab-ci.yml           ← Pipeline CI/CD
```

---

## Partie 1 — Déploiement Docker sans Docker Compose

Démarrer les 3 composants manuellement dans des conteneurs communicants via un réseau Docker dédié.

### Travail demandé

1. Créer un réseau Docker `employee-net` et un volume nommé `employee-pgdata`.
2. Démarrer le conteneur **PostgreSQL** avec les variables d'environnement et le script `db/init.sql` monté dans `/docker-entrypoint-initdb.d/`.
3. Builder et démarrer le conteneur **Backend Flask** (nommé `backend` pour que le proxy Nginx le resolve).
4. Builder et démarrer le conteneur **Frontend Nginx**.
5. Vérifier via `curl http://localhost/health` et `curl http://localhost/api/employees`.

### Commandes attendues

```bash
# Réseau et volume
docker network create employee-net
docker volume create employee-pgdata

# PostgreSQL
docker run -d \
  --name employee-db \
  --network employee-net \
  -e POSTGRES_DB=employeedb \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -v employee-pgdata:/var/lib/postgresql/data \
  -v $(pwd)/db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro \
  postgres:15-alpine

# Backend
docker build -t employee-backend ./backend
docker run -d \
  --name backend \
  --network employee-net \
  -e DB_HOST=employee-db \
  -e DB_PORT=5432 \
  -e DB_NAME=employeedb \
  -e DB_USER=postgres \
  -e DB_PASSWORD=postgres \
  -p 5000:5000 \
  employee-backend

# Frontend
docker build -t employee-frontend ./frontend
docker run -d \
  --name employee-frontend \
  --network employee-net \
  -p 80:80 \
  employee-frontend
```

### Livrables
- Commandes `docker run` documentées
- Capture d'écran de `docker ps` avec les 3 conteneurs `Up`
- Capture d'écran de l'application accessible sur `http://localhost`

---

## Partie 2 — Déploiement avec Docker Compose

Orchestrer les 3 services avec un fichier `docker-compose.yml` unique.

### Travail demandé

1. Définir les 3 services (`db`, `backend`, `frontend`) dans `docker-compose.yml`.
2. Configurer `depends_on` avec `condition: service_healthy` pour le backend.
3. Monter `db/init.sql` pour l'initialisation automatique de la base.
4. Utiliser un fichier `.env` pour les variables sensibles.
5. Lancer avec `docker compose up -d` et vérifier.
6. Tester la persistance : arrêter, relancer, vérifier que les données sont conservées.

### Points clés
- Le service backend doit s'appeler `backend` (résolution DNS par le proxy Nginx).
- Le `.env` ne doit pas être commité (ajouté au `.gitignore`).
- Les services `backend` et `frontend` supportent la variable `BACKEND_IMAGE` / `FRONTEND_IMAGE` pour utiliser les images du registry en CI.

### Livrables
- `docker-compose.yml`
- Capture d'écran de `docker compose ps` avec les 3 services `Up`

---

## Partie 3 — CI/CD GitLab — Déploiement simple

Automatiser le build et le déploiement via un pipeline GitLab CI/CD.

### Variables CI/CD à configurer dans GitLab

| Variable               | Description                              | Masked |
|------------------------|------------------------------------------|--------|
| `DEPLOY_SERVER`        | IP du serveur de production              | non    |
| `DEPLOY_USER`          | Utilisateur SSH (ex: `ubuntu`)           | non    |
| `DEPLOY_SSH_KEY`       | Contenu brut de la clé privée SSH        | oui    |
| `DB_PASSWORD`          | Mot de passe PostgreSQL                  | oui    |
| `CI_REGISTRY_USER`     | Login GitLab                             | non    |
| `CI_REGISTRY_PASSWORD` | Personal Access Token GitLab             | oui    |
| `GITLAB_API_TOKEN`     | Token GitLab (scope `api`)               | oui    |

### Stages du pipeline

| Stage    | Job                         | Déclenchement            |
|----------|-----------------------------|--------------------------|
| `test`   | lint (flake8) + pytest      | toutes branches + MR     |
| `build`  | build + push registry       | `main`, `develop`        |
| `deploy` | deploy via SSH + docker compose | `main`, `develop`    |
| `deploy` | commentaire automatique MR  | merge request uniquement |

### Travail demandé

1. Configurer les variables CI/CD dans GitLab.
2. S'assurer que le serveur cible a le dossier `/opt/projets/employee-app` avec le fichier `.env`.
3. Pusher sur `main` ou `develop` et vérifier les 3 stages au vert.

### Livrables
- Capture d'écran du pipeline GitLab avec les stages au vert
- Capture d'écran de l'application déployée

---

## Partie 4 — CI/CD GitLab — Déploiement Blue/Green

Déploiement sans interruption de service via deux environnements alternants.

### Principe

| Environnement | Port | Rôle                        |
|---------------|------|-----------------------------|
| Blue          | 8080 | Production actuelle         |
| Green         | 8081 | Nouvelle version (inactive) |

Le pipeline déploie sur l'environnement inactif, vérifie le `/health`, puis bascule le reverse proxy Nginx.

### Travail demandé

1. Créer `docker-compose.blue.yml` (port 8080) et `docker-compose.green.yml` (port 8081).
2. Installer Nginx sur le serveur comme reverse proxy avec `nginx-bluegreen.conf.tpl`.
3. Ajouter le job `deploy_production` dans le pipeline qui :
   - Détecte l'environnement actif via `/opt/projets/employee-app/.active_env`
   - Déploie sur l'environnement inactif
   - Valide le health check (30 tentatives × 2s)
   - Bascule Nginx et sauvegarde le nouvel état
4. Ajouter un job `rollback` déclenché manuellement.

### Livrables
- `docker-compose.blue.yml` et `docker-compose.green.yml`
- `nginx/nginx-bluegreen.conf.tpl`
- `.gitlab-ci.yml` avec jobs `deploy_production` et `rollback`
- Capture d'écran du basculement Blue → Green

---

## Partie 5 — Règles de déclenchement par branche

### Comportement attendu

| Branche      | Jobs exécutés                    |
|--------------|----------------------------------|
| `feature/*`  | `test` uniquement                |
| `develop`    | `test` + `build` + `deploy`      |
| `main`       | `test` + `build` + `deploy`      |

Implémenté via les directives `rules` dans chaque job du `.gitlab-ci.yml`.

### Livrables
- Captures d'écran des pipelines sur chaque type de branche

---

## Partie 6 — Déclenchement via Merge Request

### Comportement attendu

Sur ouverture/mise à jour d'une MR :
- Exécution des tests + lint
- Commentaire automatique sur la MR avec les résultats (`comment_mr`)
- Blocage de la fusion si les tests échouent (protection de branche GitLab)

Détecté via `$CI_PIPELINE_SOURCE == "merge_request_event"`.

### Livrables
- Capture d'écran d'une MR avec le commentaire automatique de résultats

---

## Critères d'évaluation

| Partie    | Description                                     | Points |
|-----------|-------------------------------------------------|--------|
| 1         | Docker sans Compose : 3 conteneurs communicants | 4      |
| 2         | Docker Compose : services, volumes, .env        | 4      |
| 3         | GitLab CI : test + build + deploy               | 5      |
| 4         | Blue/Green : basculement sans downtime          | 5      |
| 5         | Déclenchement par push (multi-branches)         | 3      |
| 6         | Déclenchement par Merge Request                 | 4      |
| **Bonus** | Rollback automatique en cas d'échec             | +3     |
| **Total** |                                                 | **25** |

---

## Contraintes techniques

- Images taguées avec `$CI_COMMIT_SHORT_SHA`.
- Secrets uniquement via variables CI/CD GitLab (jamais en clair dans les fichiers versionnés).
- Le `.env` reste sur le serveur, il n'est pas commité ni copié par le pipeline.
- Le service backend doit s'appeler `backend` dans Docker Compose (résolution DNS Nginx).
- Le backend expose `GET /health` → `HTTP 200` pour les health checks du pipeline.
