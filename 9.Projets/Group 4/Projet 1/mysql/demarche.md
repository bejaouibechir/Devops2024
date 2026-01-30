# Déploiement MySQL sur Kubernetes - Démarche Manuelle

## Objectif

Déployer une instance MySQL sur Kubernetes avec StatefulSet, persistance des données et services.

## Prérequis

- Cluster Kubernetes opérationnel (Minikube)
- `kubectl` installé et configuré
- Accès au cluster vérifié

## Vérifications préalables

### 1. Vérifier kubectl

```bash
kubectl version --client
```

### 2. Vérifier la connexion au cluster

```bash
kubectl cluster-info
```

### 3. Afficher les informations du cluster

```bash
kubectl cluster-info
kubectl get nodes
```

## Étape 1 - Créer le namespace

### Commande

```bash
kubectl apply -f 00-namespace.yaml
```

### Vérification

```bash
kubectl get namespace mysql-app
```

**Résultat attendu:**

```
NAME        STATUS   AGE
mysql-app   Active   5s
```

---

## Étape 2 - Créer les secrets

### Commande

```bash
kubectl apply -f 01-secret.yaml
```

### Vérification

```bash
kubectl get secrets -n mysql-app
```

**Résultat attendu:**

```
NAME            TYPE     DATA   AGE
mysql-secrets   Opaque   4      5s
```

### Voir le contenu du secret (base64 encodé)

```bash
kubectl get secret mysql-secrets -n mysql-app -o yaml
```

---

## Étape 3 - Créer le ConfigMap

### Commande

```bash
kubectl apply -f 02-configmap.yaml
```

### Vérification

```bash
kubectl get configmap -n mysql-app
```

**Résultat attendu:**

```
NAME                DATA   AGE
mysql-init-script   1      5s
```

### Voir le contenu du ConfigMap

```bash
kubectl describe configmap mysql-init-script -n mysql-app
```

---

## Étape 4 - Créer le StatefulSet MySQL

### Important

⚠️ Utiliser le fichier corrigé `03-statefulset-fixed.yaml` (avec probes authentifiées)

### Commande

```bash
# Remplacer le fichier original par la version corrigée
cp 03-statefulset-fixed.yaml 03-statefulset.yaml

# Déployer
kubectl apply -f 03-statefulset.yaml
```

### Vérification

```bash
kubectl get statefulset -n mysql-app
```

**Résultat attendu:**

```
NAME    READY   AGE
mysql   0/1     10s
```

### Attendre que le pod soit prêt

```bash
kubectl wait --for=condition=ready pod -l app=mysql -n mysql-app --timeout=300s
```

### Vérifier les pods

```bash
kubectl get pods -n mysql-app -o wide
```

**Résultat attendu:**

```
NAME      READY   STATUS    RESTARTS   AGE
mysql-0   1/1     Running   0          2m
```

### Voir les logs MySQL

```bash
kubectl logs -n mysql-app mysql-0
```

### Vérifier le PersistentVolumeClaim

```bash
kubectl get pvc -n mysql-app
```

**Résultat attendu:**

```
NAME                STATUS   VOLUME                                     CAPACITY
mysql-data-mysql-0  Bound    pvc-xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx     5Gi
```

---

## Étape 5 - Créer les services

### Commande

```bash
kubectl apply -f 04-services.yaml
```

### Vérification

```bash
kubectl get services -n mysql-app
```

**Résultat attendu:**

```
NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
mysql-headless    ClusterIP   None            <none>        3306/TCP         10s
mysql-service     ClusterIP   10.96.100.100   <none>        3306/TCP         10s
mysql-nodeport    NodePort    10.96.100.101   <none>        3306:30306/TCP   10s
```

### Description des services

```bash
kubectl describe svc mysql-service -n mysql-app
```

---

## Étape 6 - Tester la connexion MySQL

### Test 1 - Connexion root depuis le pod

```bash
kubectl exec -n mysql-app mysql-0 -- mysql -uroot -p'MySecureP@ssw0rd2024!' -e "SELECT 1"
```

**Résultat attendu:**

```
1
1
```

### Test 2 - Voir les bases de données

```bash
kubectl exec -n mysql-app mysql-0 -- mysql -uroot -p'MySecureP@ssw0rd2024!' -e "SHOW DATABASES;"
```

**Résultat attendu:**

```
Database
information_schema
businessdb
mysql
performance_schema
sys
```

### Test 3 - Vérifier la table employees

```bash
kubectl exec -n mysql-app mysql-0 -- mysql -uroot -p'MySecureP@ssw0rd2024!' -D businessdb -e "SELECT * FROM employees;"
```

**Résultat attendu:** 5 employés affichés

### Test 4 - Test avec utilisateur applicatif

```bash
kubectl exec -n mysql-app mysql-0 -- mysql -uappuser -p'AppU5er@2024' -D businessdb -e "SELECT COUNT(*) FROM employees;"
```

**Résultat attendu:**

```
COUNT(*)
5
```

---

## Étape 7 - Vérifier le statut complet

### Voir toutes les ressources

```bash
kubectl get all -n mysql-app
```

### Namespace

```bash
kubectl get namespace mysql-app
```

### StatefulSet

```bash
kubectl get statefulset -n mysql-app
kubectl describe statefulset mysql -n mysql-app
```

### Pods

```bash
kubectl get pods -n mysql-app -o wide
kubectl describe pod mysql-0 -n mysql-app
```

### Services

```bash
kubectl get services -n mysql-app
```

### PersistentVolumeClaims

```bash
kubectl get pvc -n mysql-app
kubectl describe pvc mysql-data-mysql-0 -n mysql-app
```

### Secrets

```bash
kubectl get secrets -n mysql-app
```

### ConfigMaps

```bash
kubectl get configmaps -n mysql-app
```

---

## Informations de connexion

### Depuis l'intérieur du cluster

**Hostname:**

```
mysql-service.mysql-app.svc.cluster.local
```

**Port:** 3306

**Credentials:**

- Database: `businessdb`
- User: `appuser`
- Password: `AppU5er@2024`

**Commande de connexion:**

```bash
mysql -h mysql-service.mysql-app.svc.cluster.local -u appuser -p'AppU5er@2024' businessdb
```

### Depuis l'extérieur (NodePort sur Minikube)

**Pour Minikube, utiliser minikube service:**

```bash
minikube service mysql-nodeport -n mysql-app --url
```

**Exemple de connexion:**

```bash
mysql -h 192.168.49.2 -P 30306 -u appuser -p'AppU5er@2024' businessdb
```

### Avec Port-forward (accès local)

```bash
# Lancer port-forward
kubectl port-forward -n mysql-app svc/mysql-service 3306:3306 &

# Se connecter
mysql -h 127.0.0.1 -P 3306 -u appuser -p'AppU5er@2024' businessdb
```

---

## Commandes utiles

### Voir les logs MySQL en temps réel

```bash
kubectl logs -n mysql-app mysql-0 -f
```

### Se connecter au pod MySQL (shell interactif)

```bash
kubectl exec -it -n mysql-app mysql-0 -- bash
```

Une fois dans le pod:

```bash
mysql -uroot -p'MySecureP@ssw0rd2024!'
```

### Redémarrer MySQL

```bash
kubectl rollout restart statefulset/mysql -n mysql-app
```

### Voir les événements du namespace

```bash
kubectl get events -n mysql-app --sort-by='.lastTimestamp'
```

### Voir l'utilisation des ressources

```bash
kubectl top pod mysql-0 -n mysql-app
```

---

## Tests de persistance des données

### 1. Insérer une donnée de test

```bash
kubectl exec -n mysql-app mysql-0 -- mysql -uappuser -p'AppU5er@2024' -D businessdb -e \
  "INSERT INTO employees (name, address, salary, department, hire_date) VALUES ('Test User', '123 Test St', 50000, 'IT', '2024-01-30');"
```

### 2. Vérifier l'insertion

```bash
kubectl exec -n mysql-app mysql-0 -- mysql -uappuser -p'AppU5er@2024' -D businessdb -e \
  "SELECT * FROM employees WHERE name='Test User';"
```

### 3. Supprimer le pod (simuler un crash)

```bash
kubectl delete pod mysql-0 -n mysql-app
```

### 4. Attendre que le pod redémarre

```bash
kubectl wait --for=condition=ready pod mysql-0 -n mysql-app --timeout=300s
```

### 5. Vérifier que les données persistent

```bash
kubectl exec -n mysql-app mysql-0 -- mysql -uappuser -p'AppU5er@2024' -D businessdb -e \
  "SELECT * FROM employees WHERE name='Test User';"
```

**Résultat attendu:** La donnée de test est toujours présente

---

## Troubleshooting

### Le pod ne démarre pas

```bash
# Voir les événements
kubectl describe pod mysql-0 -n mysql-app

# Voir les logs
kubectl logs -n mysql-app mysql-0

# Vérifier le StatefulSet
kubectl describe statefulset mysql -n mysql-app
```

### Problème de PVC

```bash
# Vérifier les PVC
kubectl get pvc -n mysql-app

# Voir les détails
kubectl describe pvc mysql-data-mysql-0 -n mysql-app

# Vérifier les StorageClass disponibles
kubectl get storageclass
```

### Erreur de connexion MySQL

```bash
# Vérifier que le pod est ready
kubectl get pod mysql-0 -n mysql-app

# Tester la connexion depuis le pod
kubectl exec -n mysql-app mysql-0 -- mysqladmin ping -h localhost -pMySecureP@ssw0rd2024!

# Vérifier les logs MySQL
kubectl logs -n mysql-app mysql-0 | grep -i error
```

### Probes qui échouent

```bash
# Vérifier les événements du pod
kubectl describe pod mysql-0 -n mysql-app | grep -i probe

# Vérifier que les probes sont correctement configurées avec authentification
kubectl get statefulset mysql -n mysql-app -o yaml | grep -A 10 livenessProbe
```

---

## Nettoyage (suppression complète)

### ⚠️ Attention: Cette opération supprime toutes les données

### 1. Supprimer les services

```bash
kubectl delete -f 04-services.yaml
```

### 2. Supprimer le StatefulSet

```bash
kubectl delete -f 03-statefulset.yaml
```

### 3. Supprimer le ConfigMap

```bash
kubectl delete -f 02-configmap.yaml
```

### 4. Supprimer les secrets

```bash
kubectl delete -f 01-secret.yaml
```

### 5. Supprimer les PVCs (⚠️ perte des données)

```bash
kubectl delete pvc -n mysql-app --all
```

### 6. Supprimer le namespace

```bash
kubectl delete -f 00-namespace.yaml
```

### Vérifier la suppression

```bash
kubectl get all -n mysql-app
```

---

## Résumé des commandes de déploiement

```bash
# 1. Namespace
kubectl apply -f 00-namespace.yaml

# 2. Secrets
kubectl apply -f 01-secret.yaml

# 3. ConfigMap
kubectl apply -f 02-configmap.yaml

# 4. StatefulSet (version corrigée)
cp 03-statefulset-fixed.yaml 03-statefulset.yaml
kubectl apply -f 03-statefulset.yaml

# 5. Services
kubectl apply -f 04-services.yaml

# 6. Attendre que MySQL soit prêt
kubectl wait --for=condition=ready pod -l app=mysql -n mysql-app --timeout=300s

# 7. Tester
kubectl exec -n mysql-app mysql-0 -- mysql -uroot -p'MySecureP@ssw0rd2024!' -e "SELECT 1"
```

---

## Points clés à retenir

1. **Ordre de déploiement** : Namespace → Secrets → ConfigMap → StatefulSet → Services
2. **Fichier corrigé** : Utiliser `03-statefulset-fixed.yaml` (probes avec authentification)
3. **Persistance** : Les données sont stockées dans un PersistentVolumeClaim
4. **Services** : 3 services créés (Headless, ClusterIP, NodePort)
5. **Initialisation** : Le script SQL dans le ConfigMap s'exécute au premier démarrage
6. **Credentials** : Root (`MySecureP@ssw0rd2024!`) et appuser (`AppU5er@2024`)
