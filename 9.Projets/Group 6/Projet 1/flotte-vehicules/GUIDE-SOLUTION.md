# Guide de solution — Déploiement pas à pas (manuel → automatisé)

Ce guide explique **comment déployer la solution à la main** (Docker Compose puis Kubernetes), de façon pédagogique.  
Dans cette première phase, **on n’automatise pas** le déploiement via GitLab CI/CD. L’automatisation viendra ensuite.

---

## 0) Prérequis

### Sur votre poste (Windows)
- Docker Desktop installé et démarré (avec `docker compose`)
- `curl` disponible (PowerShell ok)
- (Option K8s local) `kubectl` + un cluster (Docker Desktop K8s, Minikube, k3d, etc.)

### Sur le serveur `sv2` (déploiement Docker manuel)
- Linux avec Docker + Docker Compose plugin installés
- Accès SSH (ex: `ssh root@SV2_HOST`)
- Les ports ouverts si vous voulez accéder depuis l’extérieur :
  - Frontend : `8080`
  - Backend : `5000`
  - SQL Server : `1433` (souvent réservé/à éviter d’exposer publiquement)

---

## 1) Déploiement local (Docker Compose)

Placez-vous à la racine du projet :

```powershell
cd "C:\Users\DELL\Desktop\Projets session 6\Projet1g6\flotte-vehicules"
```

### 1.1 Démarrer la stack

Définissez un mot de passe SA (respectez les contraintes SQL Server : complexité, longueur, etc.) :

```powershell
$env:SA_PASSWORD="FlotteDevOps2024!"
docker compose up -d --build
docker compose ps
```

Attendez ~30–60s le premier démarrage de SQL Server.

### 1.2 Vérifier le backend

```powershell
curl http://localhost:5000/api/vehicules
```

Vous devez obtenir une liste JSON (normalement avec des données seedées via `database/init.sql`).

Swagger :
- `http://localhost:5000/swagger`

### 1.3 Vérifier le frontend

- `http://localhost:8080`

Le frontend appelle l’API sur `http://<host>:5000` (détecté automatiquement via le hostname courant).

### 1.4 Dépannage rapide

- Logs backend :
  ```powershell
  docker compose logs backend --tail 200
  ```
- Logs DB :
  ```powershell
  docker compose logs db --tail 200
  ```
- Stopper :
  ```powershell
  docker compose down
  ```

---

## 2) Déploiement manuel sur `sv2` (Docker Compose)

Objectif : lancer les **3 conteneurs** sur le serveur, **sans CI/CD**.

### 2.1 Copier le projet sur le serveur

Option A (simple) : copier tout le dossier `flotte-vehicules/` sur le serveur.

Depuis votre poste (adaptez l’utilisateur/host) :

```powershell
scp -r "C:\Users\DELL\Desktop\Projets session 6\Projet1g6\flotte-vehicules" root@SV2_HOST:/root/
```

### 2.2 Lancer la stack sur le serveur

Sur le serveur :

```bash
cd /root/flotte-vehicules
export SA_PASSWORD='FlotteDevOps2024!'
docker compose up -d --build
docker compose ps
```

### 2.3 Tester depuis le serveur

```bash
curl http://localhost:5000/api/vehicules
```

Si vous exposez les ports (déjà le cas dans `docker-compose.yml`), testez depuis votre poste :
- `http://SV2_HOST:8080`
- `http://SV2_HOST:5000/swagger`

---

## 3) Déploiement Kubernetes (manuel)

### 3.1 Préparer les images

Pour Kubernetes, vos nœuds doivent pouvoir **pull** les images.

Deux approches possibles :
- **Registry** (recommandé) : vous poussez les images sur un registry (GitLab Container Registry plus tard).
- **Cluster local** : vous “chargez” les images dans le cluster (Minikube/k3d ont des commandes dédiées).

Les manifests actuels référencent des images “exemple” dans `k8s/*.yaml` (à adapter à votre registry).

### 3.2 Créer le namespace + ressources

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/sqlserver-secret.yaml
kubectl apply -f k8s/sqlserver-pvc.yaml
kubectl apply -f k8s/sqlserver-service.yaml
kubectl apply -f k8s/sqlserver-statefulset.yaml
kubectl apply -f k8s/backend-configmap.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
```

Vérifications :

```bash
kubectl get pods -n flotte
kubectl get svc -n flotte
```

### 3.3 Accéder à l’application

Le service frontend est en `NodePort` `30080` (voir `k8s/frontend-service.yaml`) :
- `http://<node-ip>:30080`

### 3.4 Tester SQL Server dans le pod

```bash
kubectl exec -it -n flotte statefulset/sqlserver -- /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'FlotteDevOps2024!' -Q "SELECT name FROM sys.databases"
```

---

## 4) Bonus supervision (Prometheus + Grafana)

Appliquer le dossier bonus :

```bash
kubectl apply -f k8s/bonus/
kubectl get pods -n flotte
kubectl get svc -n flotte
```

Accès (NodePort) :
- Prometheus : `http://<node-ip>:30090`
- Grafana : `http://<node-ip>:30030` (admin/admin)

---

## 5) Phase 2 (à faire ensuite) : automatisation GitLab CI/CD

Une fois le déploiement manuel validé :
- On ajoute un pipeline GitLab en 2 stages `build` puis `deploy`.
- `build` : build/push des 3 images (backend/frontend/database) vers le registry GitLab.
- `deploy` : SSH vers `sv2` + `docker compose pull` + `docker compose up -d`.

Quand vous me donnez le feu vert pour la phase 2, je vous génère le `.gitlab-ci.yml` adapté à votre projet GitLab (registry path, variables, user SSH, etc.).

