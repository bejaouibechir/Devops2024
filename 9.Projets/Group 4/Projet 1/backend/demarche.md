# Backend Flask MySQL - PARTIE I : Build & Push Docker Hub - Démarche Manuelle

## Objectif

Construire l'image Docker du backend Flask, la tester localement, puis la pousser sur Docker Hub.

## Prérequis

- Docker installé
- Compte Docker Hub créé
- MySQL déployé sur Kubernetes (optionnel pour test)
- Être dans le répertoire `backend/`

## Structure des fichiers

```
backend/
├── src/
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
└── (autres fichiers)
```

---

## Étape 1 - Vérifier les prérequis

### Vérifier Docker installé

```bash
docker --version
```

**Résultat attendu:**

```
Docker version 24.x.x, build xxxxx
```

### Vérifier présence des fichiers source

```bash
ls -la src/
```

**Résultat attendu:**

```
Dockerfile
app.py
requirements.txt
```

### Vérifier compte Docker Hub

Assurez-vous d'avoir un compte sur https://hub.docker.com

---

## Étape 2 - Build de l'image Docker

### Se placer dans le répertoire source

```bash
cd src
```

### Builder l'image

```bash
docker build -t mysql-flask-backend:1.0 .
```

**Résultat attendu:**

```
[+] Building 15.2s (12/12) FINISHED
 => [internal] load build definition from Dockerfile
 => => transferring dockerfile: 682B
 => [internal] load .dockerignore
 => [internal] load metadata for docker.io/library/python:3.11-slim
 => [1/6] FROM docker.io/library/python:3.11-slim
 => [internal] load build context
 => => transferring context: 9.54kB
 => [2/6] WORKDIR /app
 => [3/6] COPY requirements.txt .
 => [4/6] RUN pip install --no-cache-dir -r requirements.txt
 => [5/6] COPY app.py .
 => [6/6] RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
 => exporting to image
 => => exporting layers
 => => writing image sha256:xxxxxxxxxxxx
 => => naming to docker.io/library/mysql-flask-backend:1.0
```

### Retourner au répertoire backend

```bash
cd ..
```

### Vérifier que l'image est créée

```bash
docker images | grep mysql-flask-backend
```

**Résultat attendu:**

```
mysql-flask-backend   1.0       xxxxxxxxxxxx   2 minutes ago   180MB
```

---

## Étape 3 - Tester l'image avec un container

### Nettoyer ancien container de test (si existe)

```bash
docker rm -f test-flask-backend
```

### Démarrer le container de test

```bash
docker run -d \
  --name test-flask-backend \
  -p 5000:5000 \
  -e MYSQL_HOST=mysql-service.mysql-app.svc.cluster.local \
  -e MYSQL_PORT=3306 \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=AppU5er@2024 \
  -e MYSQL_DATABASE=businessdb \
  mysql-flask-backend:1.0
```

**Résultat attendu:**

```
xxxxxxxxxxxx (container ID)
```

### Vérifier que le container tourne

```bash
docker ps | grep test-flask-backend
```

**Résultat attendu:**

```
xxxxxxxxxxxx   mysql-flask-backend:1.0   "python app.py"   5 seconds ago   Up 4 seconds   0.0.0.0:5000->5000/tcp   test-flask-backend
```

### Attendre que l'application démarre

```bash
sleep 5
```

### Voir les logs du container

```bash
docker logs test-flask-backend
```

**Résultat attendu:**

```
 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://172.17.0.x:5000
Press CTRL+C to quit
```

---

## Étape 4 - Tester les endpoints

### Test endpoint racine

```bash
curl http://localhost:5000/
```

**Résultat attendu:**

```json
{
  "message": "MySQL Backend API",
  "version": "1.0",
  "endpoints": {
    "/health": "Health check",
    "/employees": "GET all employees, POST new employee",
    "/employees/<id>": "GET, PUT, DELETE specific employee",
    "/stats": "GET database statistics"
  }
}
```

### Test health check

```bash
curl http://localhost:5000/health
```

**Résultat attendu (si MySQL accessible):**

```json
{
  "database": "connected",
  "status": "healthy",
  "timestamp": "2024-01-30T..."
}
```

**Ou (si MySQL non accessible - c'est normal):**

```json
{
  "database": "disconnected",
  "status": "unhealthy",
  "timestamp": "2024-01-30T..."
}
```

⚠️ **Note:** Si MySQL n'est pas accessible depuis Docker (normal), le health check échouera. Ce n'est pas grave, l'image fonctionne. Elle sera testée dans Kubernetes où MySQL est accessible.

### Voir les logs du test

```bash
docker logs test-flask-backend | tail -20
```

---

## Étape 5 - Nettoyage du container de test

### Arrêter le container

```bash
docker stop test-flask-backend
```

### Supprimer le container

```bash
docker rm test-flask-backend
```

### Vérifier la suppression

```bash
docker ps -a | grep test-flask-backend
```

**Résultat attendu:** Aucune ligne

---

## Étape 6 - Tag de l'image pour Docker Hub

### Définir votre username Docker Hub

```bash
# Remplacer par votre username Docker Hub
DOCKER_USERNAME="votre-username"
```

### Tagger l'image

```bash
docker tag mysql-flask-backend:1.0 ${DOCKER_USERNAME}/mysql-flask-backend:1.0
docker tag mysql-flask-backend:1.0 ${DOCKER_USERNAME}/mysql-flask-backend:latest
```

### Vérifier les tags

```bash
docker images | grep mysql-flask-backend
```

**Résultat attendu:**

```
votre-username/mysql-flask-backend   1.0      xxxxxxxxxxxx   10 minutes ago   180MB
votre-username/mysql-flask-backend   latest   xxxxxxxxxxxx   10 minutes ago   180MB
mysql-flask-backend                  1.0      xxxxxxxxxxxx   10 minutes ago   180MB
```

---

## Étape 7 - Login Docker Hub

### Se connecter à Docker Hub

```bash
docker login
```

**Prompts:**

```
Username: votre-username
Password: votre-password
```

**Résultat attendu:**

```
Login Succeeded
```

### Vérifier la connexion

```bash
docker info | grep Username
```

**Résultat attendu:**

```
Username: votre-username
```

---

## Étape 8 - Push vers Docker Hub

### Pousser l'image tag 1.0

```bash
docker push ${DOCKER_USERNAME}/mysql-flask-backend:1.0
```

**Résultat attendu:**

```
The push refers to repository [docker.io/votre-username/mysql-flask-backend]
xxxxxxxxxxxx: Pushed
xxxxxxxxxxxx: Pushed
xxxxxxxxxxxx: Pushed
xxxxxxxxxxxx: Pushed
xxxxxxxxxxxx: Pushed
1.0: digest: sha256:xxxxxxxxxxxx size: 1234
```

### Pousser l'image tag latest

```bash
docker push ${DOCKER_USERNAME}/mysql-flask-backend:latest
```

**Résultat attendu:**

```
The push refers to repository [docker.io/votre-username/mysql-flask-backend]
xxxxxxxxxxxx: Layer already exists
xxxxxxxxxxxx: Layer already exists
xxxxxxxxxxxx: Layer already exists
xxxxxxxxxxxx: Layer already exists
xxxxxxxxxxxx: Layer already exists
latest: digest: sha256:xxxxxxxxxxxx size: 1234
```

---

## Étape 9 - Vérifier sur Docker Hub

### Accéder à Docker Hub

Ouvrir dans le navigateur:

```
https://hub.docker.com/r/VOTRE-USERNAME/mysql-flask-backend
```

### Vérifier les tags

Dans Docker Hub, onglet **Tags**, vous devriez voir:

- `1.0`
- `latest`

---

## Résumé des commandes

```bash
# 1. Build
cd src
docker build -t mysql-flask-backend:1.0 .
cd ..

# 2. Test
docker run -d --name test-flask-backend -p 5000:5000 \
  -e MYSQL_HOST=mysql-service.mysql-app.svc.cluster.local \
  -e MYSQL_USER=appuser -e MYSQL_PASSWORD=AppU5er@2024 \
  -e MYSQL_DATABASE=businessdb \
  mysql-flask-backend:1.0

# 3. Tester
curl http://localhost:5000/
curl http://localhost:5000/health
docker logs test-flask-backend

# 4. Nettoyage
docker stop test-flask-backend
docker rm test-flask-backend

# 5. Tag
DOCKER_USERNAME="votre-username"
docker tag mysql-flask-backend:1.0 ${DOCKER_USERNAME}/mysql-flask-backend:1.0
docker tag mysql-flask-backend:1.0 ${DOCKER_USERNAME}/mysql-flask-backend:latest

# 6. Login
docker login

# 7. Push
docker push ${DOCKER_USERNAME}/mysql-flask-backend:1.0
docker push ${DOCKER_USERNAME}/mysql-flask-backend:latest
```

---

## Troubleshooting

### Build échoue

**Vérifier fichiers source:**

```bash
ls -la src/
cat src/Dockerfile
cat src/requirements.txt
```

**Voir logs détaillés:**

```bash
docker build -t mysql-flask-backend:1.0 src/ --no-cache --progress=plain
```

### Container ne démarre pas

**Voir logs:**

```bash
docker logs test-flask-backend
```

**Inspecter container:**

```bash
docker inspect test-flask-backend
```

### Health check échoue

**C'est normal si MySQL n'est pas accessible depuis Docker.**

Le container Docker tourne en dehors de Kubernetes et ne peut pas atteindre le service MySQL dans le cluster.

**Solution:** Continuer avec le push. L'image sera testée dans Kubernetes.

### Push échoue

**Vérifier login:**

```bash
docker info | grep Username
```

**Re-login si nécessaire:**

```bash
docker logout
docker login
```

**Vérifier tag:**

```bash
docker images | grep mysql-flask-backend
```

Le tag doit commencer par votre username: `votre-username/mysql-flask-backend`

### "unauthorized: authentication required"

**Se reconnecter:**

```bash
docker login
```

Entrer username et password Docker Hub.

---

## Nettoyage (optionnel)

### Supprimer les images locales

```bash
# Image originale
docker rmi mysql-flask-backend:1.0

# Images taguées
docker rmi ${DOCKER_USERNAME}/mysql-flask-backend:1.0
docker rmi ${DOCKER_USERNAME}/mysql-flask-backend:latest
```

### Vérifier

```bash
docker images | grep mysql-flask-backend
```

---

## Prochaine étape

✅ **PARTIE I terminée**

**Image disponible sur Docker Hub:**

```
votre-username/mysql-flask-backend:1.0
```

**➡️ Passer à la PARTIE II:**

```
Déploiement Kubernetes
Voir: DEMARCHE-BACKEND-K8S.md
```

---

## Points clés à retenir

1. **Build** : `docker build` crée l'image depuis le Dockerfile
2. **Test local** : Le container démarre sur port 5000
3. **Health check** : Peut échouer si MySQL non accessible (normal)
4. **Tag** : Format `username/image:version` pour Docker Hub
5. **Login** : `docker login` avant le push
6. **Push** : Upload l'image sur Docker Hub
7. **Vérification** : Image visible sur hub.docker.com

## Variables d'environnement utilisées

```bash
MYSQL_HOST=mysql-service.mysql-app.svc.cluster.local
MYSQL_PORT=3306
MYSQL_USER=appuser
MYSQL_PASSWORD=AppU5er@2024
MYSQL_DATABASE=businessdb
```



# Backend Flask MySQL - PARTIE II : Déploiement Kubernetes - Démarche Manuelle

## Objectif

Déployer le backend Flask sur Kubernetes avec Secret, Deployment, Service et HPA (Horizontal Pod Autoscaler).

## Prérequis

- PARTIE I terminée (image sur Docker Hub)
- MySQL déployé sur Kubernetes (namespace mysql-app)
- kubectl configuré
- metrics-server activé sur Minikube

## Architecture déployée

```
Service (ClusterIP + NodePort)
    ↓
Deployment (2-10 replicas via HPA)
    ↓
Pods Flask Backend
    ↓
Service MySQL
```

---

## Étape 1 - Vérifications préalables

### Vérifier cluster Kubernetes

```bash
kubectl cluster-info
```

### Vérifier MySQL déployé et running

```bash
kubectl get statefulset mysql -n mysql-app
kubectl get pod mysql-0 -n mysql-app
```

**Résultat attendu:**

```
NAME    READY   AGE
mysql   1/1     1h

NAME      READY   STATUS    RESTARTS   AGE
mysql-0   1/1     Running   0          1h
```

### Vérifier metrics-server

```bash
kubectl get deployment metrics-server -n kube-system
```

**Si absent, activer:**

```bash
minikube addons enable metrics-server
```

---

## Étape 2 - Mettre à jour le fichier Deployment

### Éditer k8s/02-deployment.yaml

Remplacer la ligne `image:` avec votre image Docker Hub:

```yaml
containers:
- name: flask-app
  image: VOTRE-USERNAME/mysql-flask-backend:1.0  # ← Modifier ici
  imagePullPolicy: Always
```

**Exemple:**

```yaml
image: johndoe/mysql-flask-backend:1.0
```

### Vérifier le fichier

```bash
cat k8s/02-deployment.yaml | grep image:
```

**Résultat attendu:**

```yaml
image: votre-username/mysql-flask-backend:1.0
```

---

## Étape 3 - Déployer le Secret

### Commande

```bash
kubectl apply -f k8s/01-secret.yaml
```

**Résultat attendu:**

```
secret/backend-secrets created
```

### Vérification

```bash
kubectl get secret backend-secrets -n mysql-app
```

**Résultat attendu:**

```
NAME              TYPE     DATA   AGE
backend-secrets   Opaque   3      5s
```

### Voir le contenu (base64)

```bash
kubectl get secret backend-secrets -n mysql-app -o yaml
```

---

## Étape 4 - Déployer le Deployment

### Commande

```bash
kubectl apply -f k8s/02-deployment.yaml
```

**Résultat attendu:**

```
deployment.apps/flask-backend created
```

### Vérification

```bash
kubectl get deployment flask-backend -n mysql-app
```

**Résultat attendu (initial):**

```
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
flask-backend   0/2     2            0           5s
```

### Attendre que les pods soient prêts

```bash
kubectl wait --for=condition=ready pod -l app=flask-backend -n mysql-app --timeout=180s
```

**Résultat attendu:**

```
pod/flask-backend-xxxxxxxxxx-xxxxx condition met
pod/flask-backend-xxxxxxxxxx-xxxxx condition met
```

### Voir les pods

```bash
kubectl get pods -n mysql-app -l app=flask-backend
```

**Résultat attendu:**

```
NAME                            READY   STATUS    RESTARTS   AGE
flask-backend-xxxxxxxxxx-xxxxx  1/1     Running   0          1m
flask-backend-xxxxxxxxxx-xxxxx  1/1     Running   0          1m
```

### Voir logs d'un pod

```bash
POD=$(kubectl get pod -n mysql-app -l app=flask-backend -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n mysql-app $POD
```

**Résultat attendu:**

```
 * Serving Flask app 'app'
 * Running on all addresses (0.0.0.0)
 * Running on http://0.0.0.0:5000
```

---

## Étape 5 - Déployer les Services

### Commande

```bash
kubectl apply -f k8s/03-service.yaml
```

**Résultat attendu:**

```
service/flask-backend created
service/flask-backend-nodeport created
```

### Vérification

```bash
kubectl get svc -n mysql-app | grep flask
```

**Résultat attendu:**

```
flask-backend           ClusterIP   10.xx.xx.xx   <none>        5000/TCP         10s
flask-backend-nodeport  NodePort    10.xx.xx.xx   <none>        5000:30500/TCP   10s
```

---

## Étape 6 - Déployer le HPA (Horizontal Pod Autoscaler)

### Commande

```bash
kubectl apply -f k8s/04-hpa.yaml
```

**Résultat attendu:**

```
horizontalpodautoscaler.autoscaling/flask-backend-hpa created
```

### Vérification

```bash
kubectl get hpa -n mysql-app
```

**Résultat attendu (après 1-2 minutes):**

```
NAME                REFERENCE                  TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
flask-backend-hpa   Deployment/flask-backend   0%/70%, 0%/80%  2         10        2          30s
```

⚠️ **Note:** Les targets peuvent afficher `<unknown>` initialement. Attendre 1-2 minutes que metrics-server collecte les données.

### Voir détails HPA

```bash
kubectl describe hpa flask-backend-hpa -n mysql-app
```

---

## Étape 7 - Tester l'API depuis un pod

### Test health check

```bash
POD=$(kubectl get pod -n mysql-app -l app=flask-backend -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n mysql-app $POD -- python -c "import urllib.request; print(urllib.request.urlopen('http://localhost:5000/health').read().decode())"
```

**Résultat attendu:**

```json
{"database":"connected","status":"healthy","timestamp":"2024-01-30T..."}
```

### Test liste employés

```bash
kubectl exec -n mysql-app $POD -- python -c "import urllib.request; print(urllib.request.urlopen('http://localhost:5000/employees').read().decode())" | head -50
```

**Résultat attendu:** JSON avec liste des employés

---

## Étape 8 - Accéder à l'API

### Méthode 1: Port-forward (RECOMMANDÉ pour Minikube)

```bash
# Lancer port-forward
kubectl port-forward -n mysql-app svc/flask-backend 5000:5000 --address='0.0.0.0' &
```

**Ajouter exception firewall port 5000**

**Tester:**

```bash
curl http://localhost:5000/health
curl http://localhost:5000/employees
curl http://localhost:5000/stats
```

### Méthode 2: Minikube Service

```bash
# Obtenir URL
minikube service flask-backend-nodeport -n mysql-app --url
```

**Résultat exemple:**

```
http://192.168.49.2:30500
```

**Tester avec cette URL:**

```bash
curl http://192.168.49.2:30500/health
```

### Méthode 3: Depuis navigateur

```
http://VOTRE_IP:5000/health
http://VOTRE_IP:5000/employees
http://VOTRE_IP:5000/stats
```

---

## Étape 9 - Tests complets de l'API

### 1. Health check

```bash
curl http://localhost:5000/health
```

### 2. Info API

```bash
curl http://localhost:5000/
```

### 3. Liste employés

```bash
curl http://localhost:5000/employees
```

### 4. Employé spécifique

```bash
curl http://localhost:5000/employees/1
```

### 5. Créer un employé

```bash
curl -X POST http://localhost:5000/employees \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "address": "123 Test Street",
    "salary": 55000,
    "department": "IT",
    "hire_date": "2024-01-30"
  }'
```

**Résultat attendu:**

```json
{
  "id": 7,
  "message": "Employee created successfully"
}
```

### 6. Vérifier création

```bash
curl http://localhost:5000/employees/7
```

### 7. Modifier l'employé

```bash
curl -X PUT http://localhost:5000/employees/7 \
  -H "Content-Type: application/json" \
  -d '{
    "salary": 60000
  }'
```

### 8. Statistiques

```bash
curl http://localhost:5000/stats
```

### 9. Supprimer l'employé

```bash
curl -X DELETE http://localhost:5000/employees/7
```

---

## Étape 10 - Monitoring et vérifications

### Status global

```bash
kubectl get all -n mysql-app
```

### Pods backend

```bash
kubectl get pods -n mysql-app -l app=flask-backend -o wide
```

### Logs en temps réel

```bash
kubectl logs -n mysql-app -l app=flask-backend -f
```

### Métriques des pods

```bash
kubectl top pods -n mysql-app -l app=flask-backend
```

**Résultat exemple:**

```
NAME                            CPU(cores)   MEMORY(bytes)
flask-backend-xxxxxxxxxx-xxxxx  5m           45Mi
flask-backend-xxxxxxxxxx-xxxxx  3m           42Mi
```

### HPA status

```bash
kubectl get hpa -n mysql-app
kubectl describe hpa flask-backend-hpa -n mysql-app
```

---

## Test d'autoscaling (optionnel)

### Installer hey (load generator)

**Si Go installé:**

```bash
go install github.com/rakyll/hey@latest
```

**Ou utiliser Apache Bench (déjà installé):**

```bash
# Vérifier
ab -V
```

### Générer charge

**Avec hey:**

```bash
hey -z 60s -c 50 http://localhost:5000/employees
```

**Avec Apache Bench:**

```bash
ab -n 10000 -c 50 -t 60 http://localhost:5000/employees
```

### Observer autoscaling en temps réel

**Terminal 1:**

```bash
watch kubectl get hpa -n mysql-app
```

**Terminal 2:**

```bash
watch kubectl get pods -n mysql-app -l app=flask-backend
```

**Résultat attendu:**

- CPU/Memory augmentent
- HPA scale de 2 à 3, 4, 5... replicas (max 10)
- Nouveaux pods créés automatiquement

---

## Commandes utiles

### Redémarrer le backend

```bash
kubectl rollout restart deployment/flask-backend -n mysql-app
```

### Scaler manuellement

```bash
# Scaler à 5 replicas
kubectl scale deployment flask-backend -n mysql-app --replicas=5

# Vérifier
kubectl get pods -n mysql-app -l app=flask-backend
```

### Voir événements

```bash
kubectl get events -n mysql-app --sort-by='.lastTimestamp' | grep flask
```

### Décrire un pod

```bash
POD=$(kubectl get pod -n mysql-app -l app=flask-backend -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod $POD -n mysql-app
```

### Shell dans un pod

```bash
kubectl exec -it -n mysql-app $POD -- bash
```

---

## Troubleshooting

### Pods ne démarrent pas (ImagePullBackOff)

**Vérifier l'image:**

```bash
kubectl describe pod -n mysql-app -l app=flask-backend | grep -A 5 "Events:"
```

**Erreur commune:**

```
Failed to pull image "votre-username/mysql-flask-backend:1.0": rpc error: code = Unknown desc = Error response from daemon: pull access denied
```

**Solution:**

- Vérifier que l'image existe sur Docker Hub
- Vérifier le nom d'utilisateur dans 02-deployment.yaml
- Image doit être publique ou configurer imagePullSecrets

### Pods CrashLoopBackOff

**Voir logs:**

```bash
kubectl logs -n mysql-app -l app=flask-backend --tail=50
```

**Causes fréquentes:**

- MySQL non accessible
- Erreur dans le code Python
- Variables d'environnement incorrectes

**Vérifier connexion MySQL:**

```bash
POD=$(kubectl get pod -n mysql-app -l app=flask-backend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mysql-app $POD -- python -c "import mysql.connector; print(mysql.connector.connect(host='mysql-service', user='appuser', password='AppU5er@2024', database='businessdb').is_connected())"
```

### API ne répond pas

**Vérifier pods ready:**

```bash
kubectl get pods -n mysql-app -l app=flask-backend
```

**Tester depuis le pod:**

```bash
POD=$(kubectl get pod -n mysql-app -l app=flask-backend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n mysql-app $POD -- curl http://localhost:5000/health
```

**Vérifier service:**

```bash
kubectl get svc flask-backend -n mysql-app
kubectl describe svc flask-backend -n mysql-app
```

### HPA ne scale pas

**Vérifier metrics-server:**

```bash
kubectl get deployment metrics-server -n kube-system
```

**Vérifier métriques disponibles:**

```bash
kubectl top pods -n mysql-app
```

**Si pas de métriques:**

```bash
minikube addons enable metrics-server
# Attendre 1-2 minutes
kubectl top pods -n mysql-app
```

---

## Nettoyage

### Supprimer le backend

```bash
kubectl delete -f k8s/04-hpa.yaml
kubectl delete -f k8s/03-service.yaml
kubectl delete -f k8s/02-deployment.yaml
kubectl delete -f k8s/01-secret.yaml
```

### Arrêter port-forward

```bash
pkill -f "port-forward.*5000"
```

### Vérifier suppression

```bash
kubectl get all -n mysql-app | grep flask
```

---

## Résumé des commandes

```bash
# 1. Mettre à jour image dans k8s/02-deployment.yaml

# 2. Déployer
kubectl apply -f k8s/01-secret.yaml
kubectl apply -f k8s/02-deployment.yaml
kubectl apply -f k8s/03-service.yaml
kubectl apply -f k8s/04-hpa.yaml

# 3. Attendre
kubectl wait --for=condition=ready pod -l app=flask-backend -n mysql-app --timeout=180s

# 4. Port-forward
kubectl port-forward -n mysql-app svc/flask-backend 5000:5000 --address='0.0.0.0' &

# 5. Tester
curl http://localhost:5000/health
curl http://localhost:5000/employees
curl http://localhost:5000/stats

# 6. Monitoring
kubectl get pods -n mysql-app -l app=flask-backend
kubectl logs -n mysql-app -l app=flask-backend -f
kubectl get hpa -n mysql-app
kubectl top pods -n mysql-app
```

---

## Points clés à retenir

1. **Image Docker Hub** : Modifier 02-deployment.yaml avec votre username
2. **Ordre déploiement** : Secret → Deployment → Service → HPA
3. **Attendre pods ready** : Les probes vérifient /health
4. **HPA** : Scale automatique de 2 à 10 replicas
5. **Port-forward** : Méthode recommandée pour Minikube
6. **Tests** : API complète avec CRUD employees
7. **Monitoring** : logs, metrics, HPA status

## Ressources déployées

- **Secret** : Credentials MySQL (3 valeurs)
- **Deployment** : 2 replicas (géré par HPA)
- **Service ClusterIP** : Accès interne (port 5000)
- **Service NodePort** : Accès externe (port 30500)
- **HPA** : Autoscaling 2-10 replicas (CPU 70%, Memory 80%)

## Architecture complète finale

```
┌─────────────┐
│   Browser   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│Port-forward │ :5000
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│ Service flask-backend│
└──────┬──────────────┘
       │
       ▼
┌──────────────────────────┐
│ Deployment (HPA 2-10)    │
│ ┌─────┐ ┌─────┐ ┌─────┐ │
│ │Pod 1│ │Pod 2│ │Pod N│ │
│ └──┬──┘ └──┬──┘ └──┬──┘ │
└────┼──────┼──────┼───────┘
     │      │      │
     └──────┼──────┘
            ▼
    ┌───────────────┐
    │Service MySQL  │
    └───────┬───────┘
            ▼
    ┌───────────────┐
    │ MySQL Pod     │
    └───────────────┘
```
