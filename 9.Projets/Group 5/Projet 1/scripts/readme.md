# Test de Charge - Backend Flask MySQL

## Objectif

Effectuer un test de charge sur l'API Flask pour vérifier:

- Les performances sous charge
- L'autoscaling HPA (Horizontal Pod Autoscaler)
- La stabilité de l'API
- Le comportement MySQL sous stress

## Prérequis

### 1. K6 installé

**Ubuntu/Debian:**

```bash
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6
```

**macOS:**

```bash
brew install k6
```

**Vérifier installation:**

```bash
k6 version
```

### 2. Backend déployé et accessible

```bash
# Port-forward actif
kubectl port-forward -n mysql-app svc/flask-backend 5000:5000 --address='0.0.0.0' &

# Vérifier
curl http://localhost:5000/health
```

### 3. HPA configuré

```bash
# Vérifier HPA
kubectl get hpa -n mysql-app

# Résultat attendu
NAME                REFERENCE                  TARGETS   MINPODS   MAXPODS   REPLICAS
flask-backend-hpa   Deployment/flask-backend   0%/70%    2         10        2
```

## Utilisation du script de test de charge

### Fichier: load-test.js

Le script effectue des tests sur tous les endpoints de l'API:

- GET /health
- GET /employees (avec pagination)
- GET /stats
- POST /employees (création)
- PUT /employees/:id (mise à jour)
- GET /employees/:id (lecture)
- DELETE /employees/:id (suppression)

### Phases du test

Le test se déroule en 5 phases:

1. **0-30s**: Montée progressive à 10 utilisateurs virtuels (VU)
2. **30s-1m30s**: Montée à 20 VU
3. **1m30s-2m**: Pic à 30 VU
4. **2m-3m**: Descente à 20 VU
5. **3m-3m30s**: Arrêt progressif (0 VU)

**Durée totale:** 3 minutes 30 secondes

### Lancer le test

```bash
k6 run load-test.js
```

### Options du test

**Modifier les seuils:**

Éditer `load-test.js`:

```javascript
export const options = {
  stages: [
    { duration: '30s', target: 10 },   // Modifier ici
    { duration: '1m', target: 20 },
    { duration: '30s', target: 30 },   // Pic - augmenter si besoin
    // ...
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% < 500ms
    errors: ['rate<0.1'],               // < 10% erreurs
  },
};
```

**Test rapide (30 secondes):**

```javascript
stages: [
  { duration: '10s', target: 20 },
  { duration: '10s', target: 30 },
  { duration: '10s', target: 0 },
],
```

**Test intensif (10 minutes):**

```javascript
stages: [
  { duration: '2m', target: 20 },
  { duration: '5m', target: 50 },
  { duration: '2m', target: 20 },
  { duration: '1m', target: 0 },
],
```

## Observer l'autoscaling pendant le test

### Terminal 1: Lancer le test

```bash
k6 run load-test.js
```

### Terminal 2: Observer HPA

```bash
watch -n 2 kubectl get hpa -n mysql-app
```

**Résultat attendu pendant le test:**

```
NAME                REFERENCE                  TARGETS      MINPODS   MAXPODS   REPLICAS
flask-backend-hpa   Deployment/flask-backend   75%/70%      2         10        3
```

Le HPA devrait augmenter le nombre de replicas quand CPU > 70%.

### Terminal 3: Observer les pods

```bash
watch -n 2 kubectl get pods -n mysql-app -l app=flask-backend
```

**Résultat attendu:**

```
NAME                            READY   STATUS    RESTARTS   AGE
flask-backend-xxxxxxxxxx-xxxxx  1/1     Running   0          5m
flask-backend-xxxxxxxxxx-xxxxx  1/1     Running   0          5m
flask-backend-xxxxxxxxxx-xxxxx  1/1     Running   0          1m  ← Nouveau pod créé
flask-backend-xxxxxxxxxx-xxxxx  1/1     Running   0          30s ← Nouveau pod créé
```

### Terminal 4: Observer métriques

```bash
watch -n 2 kubectl top pods -n mysql-app -l app=flask-backend
```

**Résultat pendant le test:**

```
NAME                            CPU(cores)   MEMORY(bytes)
flask-backend-xxxxxxxxxx-xxxxx  450m         85Mi
flask-backend-xxxxxxxxxx-xxxxx  420m         82Mi
flask-backend-xxxxxxxxxx-xxxxx  380m         78Mi
```

## Interpréter les résultats

### Sortie K6

```
     ✓ health check status 200
     ✓ health check is healthy
     ✓ GET employees status 200
     ✓ employees list returned
     ✓ GET stats status 200
     ✓ stats contains total_employees
     ✓ POST employee status 201
     ✓ employee created with ID
     ✓ PUT employee status 200
     ✓ GET specific employee status 200
     ✓ DELETE employee status 200

     checks.........................: 99.5%  ✓ 5432   ✗ 28
     data_received..................: 2.1 MB 600 kB/s
     data_sent......................: 850 kB 243 kB/s
     http_req_duration..............: avg=125ms min=45ms med=98ms max=450ms p(95)=285ms p(99)=380ms
     http_reqs......................: 6543   311/s
     iterations.....................: 785    37.38/s
     vus............................: 1      min=1     max=30
     vus_max........................: 30     min=30    max=30
```

### Métriques importantes

**✅ Bonnes performances:**

- `checks`: > 95% (tests réussis)
- `http_req_duration p(95)`: < 500ms
- `errors rate`: < 10%
- `http_reqs`: > 100/s

**⚠️ Performances à améliorer:**

- `checks`: < 90%
- `http_req_duration p(95)`: > 1000ms
- `errors rate`: > 20%
- Pods en CrashLoopBackOff pendant le test

### Vérifier l'autoscaling

**Avant le test:**

```bash
kubectl get hpa -n mysql-app
# REPLICAS: 2
```

**Pendant le pic (30 VU):**

```bash
kubectl get hpa -n mysql-app
# REPLICAS: 4-5 (scaling up)
```

**Après le test (5 minutes plus tard):**

```bash
kubectl get hpa -n mysql-app
# REPLICAS: 2 (scaling down)
```

## Résultats attendus

### Avec HPA fonctionnel

1. **0-30s**: 2 replicas, CPU ~40-60%
2. **30s-1m30s**: Scale up à 3-4 replicas
3. **1m30s-2m**: Scale up à 4-6 replicas (pic 30 VU)
4. **2m-3m**: Stabilisation 3-4 replicas
5. **Après test**: Scale down à 2 replicas (5-10 min)

### Performances API

- **Temps de réponse moyen**: 100-200ms
- **p(95)**: < 500ms
- **Taux de succès**: > 95%
- **Débit**: 200-500 req/s (dépend des ressources)

### Base de données MySQL

```bash
# Vérifier que MySQL est stable
kubectl logs -n mysql-app mysql-0 --tail=50

# Pas de messages d'erreur type:
# - "Too many connections"
# - "Deadlock"
# - "Lock wait timeout"
```

## Troubleshooting

### Erreurs de connexion

**Symptôme:** `connection refused`, `timeout`

**Solution:**

```bash
# Vérifier port-forward actif
ps aux | grep "port-forward.*5000"

# Relancer si nécessaire
pkill -f "port-forward.*5000"
kubectl port-forward -n mysql-app svc/flask-backend 5000:5000 --address='0.0.0.0' &
```

### Taux d'erreur élevé

**Symptôme:** `errors rate > 20%`

**Causes possibles:**

1. MySQL saturé
2. Pas assez de replicas backend
3. Ressources insuffisantes

**Solutions:**

```bash
# Augmenter les limites HPA
kubectl edit hpa flask-backend-hpa -n mysql-app
# Changer maxReplicas: 10 → 15

# Augmenter ressources MySQL
kubectl edit statefulset mysql -n mysql-app
# Augmenter memory/CPU limits

# Vérifier logs
kubectl logs -n mysql-app -l app=flask-backend --tail=100
```

### HPA ne scale pas

**Symptôme:** Replicas reste à 2 même sous charge

**Solution:**

```bash
# Vérifier metrics-server
kubectl get deployment metrics-server -n kube-system

# Activer si absent
minikube addons enable metrics-server

# Attendre 2 minutes puis vérifier
kubectl top pods -n mysql-app

# Vérifier HPA
kubectl describe hpa flask-backend-hpa -n mysql-app
```

### Pods crashent pendant le test

**Symptôme:** CrashLoopBackOff pendant le test

**Solution:**

```bash
# Voir les logs
kubectl logs -n mysql-app -l app=flask-backend --previous

# Augmenter les limites ressources
kubectl edit deployment flask-backend -n mysql-app

# Augmenter:
resources:
  limits:
    memory: "512Mi"  # au lieu de 256Mi
    cpu: "1000m"     # au lieu de 500m
```

## Test alternatif avec Apache Bench

Si K6 n'est pas disponible:

```bash
# Installer Apache Bench
sudo apt-get install apache2-utils

# Test simple (1000 requêtes, 50 concurrentes)
ab -n 1000 -c 50 http://localhost:5000/employees

# Test prolongé (60 secondes)
ab -t 60 -c 50 http://localhost:5000/employees
```

## Nettoyage après tests

```bash
# Les employés créés pendant le test sont automatiquement supprimés par le script
# Mais pour nettoyer manuellement:

# Se connecter à MySQL
kubectl exec -it -n mysql-app mysql-0 -- mysql -uroot -p'MySecureP@ssw0rd2024!' businessdb

# Supprimer employés de test
DELETE FROM employees WHERE name LIKE 'LoadTest User%';

# Vérifier
SELECT COUNT(*) FROM employees;
```

## Résumé des commandes

```bash
# 1. Installer K6
sudo apt-get install k6

# 2. Port-forward backend
kubectl port-forward -n mysql-app svc/flask-backend 5000:5000 --address='0.0.0.0' &

# 3. Lancer test
k6 run load-test.js

# 4. Observer (autres terminaux)
watch kubectl get hpa -n mysql-app
watch kubectl get pods -n mysql-app -l app=flask-backend
watch kubectl top pods -n mysql-app

# 5. Après le test
# Attendre 5-10 minutes que HPA scale down
kubectl get hpa -n mysql-app
```
