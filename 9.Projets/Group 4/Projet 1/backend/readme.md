# Backend Flask MySQL - API REST

## Architecture du projet

```
backend/
├── src/
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
├── k8s/
│   ├── 01-secret.yaml
│   ├── 02-deployment.yaml
│   ├── 03-service.yaml
│   └── 04-hpa.yaml
├── build-and-push.sh
├── deploy-backend-k8s.sh
└── README.md
```

## Prérequis

- Docker installé
- Compte Docker Hub
- Minikube avec MySQL déjà déployé
- kubectl configuré

## Installation - 2 Parties

### PARTIE I - Build & Push Docker Hub

```bash
chmod +x build-and-push.sh
./build-and-push.sh
```

**Le script effectue automatiquement:**
1. Build de l'image Docker
2. Test du container
3. Tag avec votre username Docker Hub
4. Login Docker Hub
5. Push de l'image

**Note:** Le test MySQL peut échouer (normal - MySQL est dans K8s), continuez en répondant "o".

### PARTIE II - Déploiement Kubernetes

```bash
chmod +x deploy-backend-k8s.sh
./deploy-backend-k8s.sh
```

**Le script effectue automatiquement:**
1. Vérification cluster et MySQL
2. Mise à jour du manifest avec votre image
3. Déploiement K8s (Secret, Deployment, Service, HPA)
4. Tests de l'API

## Vérification du déploiement

```bash
# Status des pods
kubectl get pods -n mysql-app -l app=flask-backend

# Logs
kubectl logs -n mysql-app -l app=flask-backend

# HPA
kubectl get hpa -n mysql-app
```

## Accès à l'API

### Méthode 1: Port-forward (RECOMMANDÉ pour Minikube)

```bash
# Lancer port-forward
kubectl port-forward -n mysql-app svc/flask-backend 5000:5000 --address='0.0.0.0' &

# Tester
curl http://localhost:5000/health
curl http://localhost:5000/employees
curl http://localhost:5000/stats
```

**Depuis navigateur:**
```
http://VOTRE_IP:5000/health
http://VOTRE_IP:5000/employees
http://VOTRE_IP:5000/stats
```

**⚠️ Ajouter exception firewall port 5000**

### Méthode 2: Minikube Service

```bash
# Obtenir URL
minikube service flask-backend-nodeport -n mysql-app --url

# Tester avec l'URL retournée
curl http://192.168.49.2:30500/health
```

### Méthode 3: Depuis un pod

```bash
POD=$(kubectl get pod -n mysql-app -l app=flask-backend -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n mysql-app $POD -- python -c "import urllib.request; print(urllib.request.urlopen('http://localhost:5000/health').read().decode())"
```

## Endpoints API

### GET / - Info API
```bash
curl http://localhost:5000/
```

### GET /health - Health check
```bash
curl http://localhost:5000/health
```

**Réponse:**
```json
{
  "database": "connected",
  "status": "healthy",
  "timestamp": "2026-01-30T21:53:01.028178"
}
```

### GET /employees - Liste des employés
```bash
# Tous les employés
curl http://localhost:5000/employees

# Avec pagination
curl http://localhost:5000/employees?page=1&per_page=5

# Filtrer par département
curl http://localhost:5000/employees?department=IT
```

**Réponse:**
```json
{
  "employees": [
    {
      "id": 1,
      "name": "Alice Dupont",
      "address": "123 Rue de Paris, 75001 Paris",
      "salary": "45000.00",
      "department": "IT",
      "hire_date": "Wed, 15 Jan 2020 00:00:00 GMT"
    },
    ...
  ],
  "total": 6,
  "page": 1,
  "per_page": 10,
  "total_pages": 1
}
```

### POST /employees - Créer un employé
```bash
curl -X POST http://localhost:5000/employees \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jean Dupont",
    "address": "10 Rue de la Paix, Paris",
    "salary": 65000,
    "department": "Engineering",
    "hire_date": "2024-01-30"
  }'
```

**Réponse:**
```json
{
  "message": "Employee created successfully",
  "id": 7
}
```

### GET /employees/<id> - Employé spécifique
```bash
curl http://localhost:5000/employees/1
```

### PUT /employees/<id> - Modifier un employé
```bash
curl -X PUT http://localhost:5000/employees/1 \
  -H "Content-Type: application/json" \
  -d '{
    "salary": 60000,
    "department": "Engineering"
  }'
```

### DELETE /employees/<id> - Supprimer un employé
```bash
curl -X DELETE http://localhost:5000/employees/6
```

### GET /stats - Statistiques
```bash
curl http://localhost:5000/stats
```

**Réponse:**
```json
{
  "total_employees": 6,
  "average_salary": 50500.0,
  "by_department": [
    {
      "department": "IT",
      "count": 3,
      "avg_salary": "51000.000000"
    },
    {
      "department": "Finance",
      "count": 1,
      "avg_salary": "55000.000000"
    }
  ],
  "salary_range": {
    "min": 43000.0,
    "max": 60000.0
  }
}
```

## Tests complets

```bash
# 1. Health check
curl http://localhost:5000/health

# 2. Liste employés
curl http://localhost:5000/employees

# 3. Créer employé
curl -X POST http://localhost:5000/employees \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","address":"Test St","salary":50000,"department":"IT"}'

# 4. Vérifier création
curl http://localhost:5000/employees

# 5. Statistiques
curl http://localhost:5000/stats

# 6. Modifier employé
curl -X PUT http://localhost:5000/employees/7 \
  -H "Content-Type: application/json" \
  -d '{"salary":55000}'

# 7. Supprimer employé
curl -X DELETE http://localhost:5000/employees/7
```

## Monitoring

### Status des ressources

```bash
# Pods backend
kubectl get pods -n mysql-app -l app=flask-backend

# Services
kubectl get svc -n mysql-app | grep flask

# HPA (autoscaling)
kubectl get hpa -n mysql-app

# Logs en temps réel
kubectl logs -n mysql-app -l app=flask-backend -f
```

### HPA Autoscaling

Le backend utilise HorizontalPodAutoscaler (HPA):
- **Min replicas:** 2
- **Max replicas:** 10
- **CPU target:** 70%
- **Memory target:** 80%

```bash
# Voir status HPA
kubectl describe hpa flask-backend-hpa -n mysql-app

# Métriques des pods
kubectl top pods -n mysql-app -l app=flask-backend
```

### Test de charge (générer autoscaling)

```bash
# Installer hey (load generator)
go install github.com/rakyll/hey@latest

# Générer charge (60 secondes, 50 connexions)
hey -z 60s -c 50 http://localhost:5000/employees

# Observer autoscaling en temps réel
watch kubectl get hpa -n mysql-app
watch kubectl get pods -n mysql-app -l app=flask-backend
```

## Troubleshooting

### Pods ne démarrent pas

```bash
# Voir détails du pod
kubectl describe pod -n mysql-app -l app=flask-backend

# Voir logs
kubectl logs -n mysql-app -l app=flask-backend

# Événements
kubectl get events -n mysql-app --sort-by='.lastTimestamp'
```

### API ne répond pas

```bash
# Vérifier pods ready
kubectl get pods -n mysql-app -l app=flask-backend

# Test depuis le pod
POD=$(kubectl get pod -n mysql-app -l app=flask-backend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mysql-app $POD -- python -c "import urllib.request; print(urllib.request.urlopen('http://localhost:5000/health').read().decode())"
```

### Erreur connexion MySQL

```bash
# Vérifier MySQL tourne
kubectl get pods -n mysql-app -l app=mysql

# Test connexion MySQL depuis backend
POD=$(kubectl get pod -n mysql-app -l app=flask-backend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mysql-app $POD -- python -c "import mysql.connector; print(mysql.connector.connect(host='mysql-service', user='appuser', password='AppU5er@2024', database='businessdb').is_connected())"
```

### HPA ne scale pas

```bash
# Vérifier metrics-server
kubectl get deployment metrics-server -n kube-system

# Si absent, activer
minikube addons enable metrics-server

# Attendre 1 minute, puis vérifier métriques
kubectl top pods -n mysql-app
```

## Variables d'environnement

Le backend utilise ces variables (définies dans Secret):

```yaml
MYSQL_HOST: mysql-service.mysql-app.svc.cluster.local
MYSQL_PORT: 3306
MYSQL_USER: appuser
MYSQL_PASSWORD: AppU5er@2024
MYSQL_DATABASE: businessdb
```

## Ressources Kubernetes

### Deployment
- **Replicas:** 2-10 (géré par HPA)
- **Image:** Votre image Docker Hub
- **Requests:** 128Mi RAM, 100m CPU
- **Limits:** 256Mi RAM, 500m CPU

### Services
- **ClusterIP:** flask-backend (port 5000)
- **NodePort:** flask-backend-nodeport (port 30500)

### HPA
- **CPU:** Scale à 70% utilisation
- **Memory:** Scale à 80% utilisation

## Nettoyage

```bash
# Supprimer backend
kubectl delete -f k8s/04-hpa.yaml
kubectl delete -f k8s/03-service.yaml
kubectl delete -f k8s/02-deployment.yaml
kubectl delete -f k8s/01-secret.yaml

# Arrêter port-forward
pkill -f "port-forward.*5000"
```

## Architecture complète

```
┌─────────────────┐
│  User/Browser   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Port-forward   │
│  :5000          │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Service        │
│  flask-backend  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────┐
│  Deployment (HPA 2-10)      │
│  ┌─────┐ ┌─────┐           │
│  │ Pod │ │ Pod │ ...       │
│  └─────┘ └─────┘           │
└─────────┬───────────────────┘
          │
          ▼
┌─────────────────┐
│  Service MySQL  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  StatefulSet    │
│  mysql-0        │
└─────────────────┘
```

## Résumé des commandes essentielles

```bash
# Build et push
./build-and-push.sh

# Déploiement K8s
./deploy-backend-k8s.sh

# Port-forward
kubectl port-forward -n mysql-app svc/flask-backend 5000:5000 --address='0.0.0.0' &

# Test API
curl http://localhost:5000/health
curl http://localhost:5000/employees
curl http://localhost:5000/stats

# Monitoring
kubectl get pods -n mysql-app
kubectl logs -n mysql-app -l app=flask-backend -f
kubectl get hpa -n mysql-app
```

## Support

En cas de problème:
1. Vérifier logs: `kubectl logs -n mysql-app -l app=flask-backend`
2. Vérifier MySQL: `kubectl get pods -n mysql-app -l app=mysql`
3. Vérifier events: `kubectl get events -n mysql-app`
