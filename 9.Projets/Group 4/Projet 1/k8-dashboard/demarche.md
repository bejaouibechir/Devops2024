# Kubernetes Dashboard - Démarche Manuelle (Minikube)

## Objectif

Installer et accéder au Kubernetes Dashboard pour visualiser et gérer les ressources du cluster.

## Prérequis

- Minikube installé et démarré
- kubectl configuré
- Accès au cluster Kubernetes

## Vérifications préalables

### 1. Vérifier Minikube

```bash
minikube status
```

**Résultat attendu:**

```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

### 2. Vérifier kubectl

```bash
kubectl cluster-info
```

---

## Étape 1 - Activer l'addon Dashboard

### Commande

```bash
minikube addons enable dashboard
```

**Résultat attendu:**

```
💡  dashboard is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
    ▪ Using image docker.io/kubernetesui/dashboard:v2.7.0
    ▪ Using image docker.io/kubernetesui/metrics-scraper:v1.0.8
💡  Some dashboard features require the metrics-server addon. To enable all features please run:

    minikube addons enable metrics-server    

🌟  The 'dashboard' addon is enabled
```

---

## Étape 2 - Activer metrics-server

### Commande

```bash
minikube addons enable metrics-server
```

**Résultat attendu:**

```
💡  metrics-server is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
    ▪ Using image registry.k8s.io/metrics-server/metrics-server:v0.6.4
🌟  The 'metrics-server' addon is enabled
```

### Vérification des addons

```bash
minikube addons list | grep -E "dashboard|metrics-server"
```

**Résultat attendu:**

```
| dashboard                   | minikube | enabled ✅   | Kubernetes        |
| metrics-server              | minikube | enabled ✅   | Kubernetes        |
```

---

## Étape 3 - Vérifier les pods Dashboard

### Attendre que les pods soient prêts

```bash
kubectl wait --for=condition=ready pod -l k8s-app=kubernetes-dashboard -n kubernetes-dashboard --timeout=120s
```

**Résultat attendu:**

```
pod/kubernetes-dashboard-xxxxxxxxxx-xxxxx condition met
```

### Voir tous les pods du dashboard

```bash
kubectl get pods -n kubernetes-dashboard
```

**Résultat attendu:**

```
NAME                                         READY   STATUS    RESTARTS   AGE
dashboard-metrics-scraper-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
kubernetes-dashboard-xxxxxxxxxx-xxxxx        1/1     Running   0          2m
```

### Vérifier les services

```bash
kubectl get svc -n kubernetes-dashboard
```

**Résultat attendu:**

```
NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
dashboard-metrics-scraper   ClusterIP   10.xxx.xxx.xxx  <none>        8000/TCP   2m
kubernetes-dashboard        ClusterIP   10.xxx.xxx.xxx  <none>        80/TCP     2m
```

---

## Étape 4 - Lancer kubectl proxy

### Important

Le proxy permet d'accéder au dashboard sans authentification.

### Arrêter les anciens proxies (si existants)

```bash
pkill -f "kubectl proxy"
```

### Lancer le proxy sur toutes les interfaces

```bash
kubectl proxy --address='0.0.0.0' --accept-hosts='.*' --port=8001 &
```

**Résultat attendu:**

```
Starting to serve on [::]:8001
```

### Vérifier que le proxy tourne

```bash
ps aux | grep "kubectl proxy"
```

**Résultat attendu:** Une ligne affichant le processus kubectl proxy

### Vérifier le port

```bash
netstat -tuln | grep 8001
```

**Résultat attendu:**

```
tcp6       0      0 :::8001                 :::*                    LISTEN
```

---

## Étape 5 - Ajouter exception firewall

### Sur AWS EC2 (Security Group)

1. Aller dans EC2 → Security Groups
2. Sélectionner le security group de votre instance
3. Inbound rules → Edit inbound rules
4. Add rule:
   - Type: Custom TCP
   - Port: 8001
   - Source: 0.0.0.0/0 (ou votre IP pour plus de sécurité)
5. Save rules

### Vérifier le firewall local (si activé)

```bash
# Vérifier si ufw est actif
sudo ufw status

# Si actif, ajouter exception
sudo ufw allow 8001/tcp
```

---

## Étape 6 - Accéder au Dashboard

### Obtenir l'URL complète

```bash
# Obtenir l'IP de votre instance
INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "http://${INSTANCE_IP}:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/"
```

### Ouvrir dans le navigateur

**URL format:**

```
http://VOTRE_IP:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

**Exemple concret:**

```
http://13.60.25.74:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

### ⚠️ Important

- Utiliser **http://** (pas https)
- Inclure le slash final `/` à la fin de l'URL
- Le proxy doit rester actif en arrière-plan

---

## Étape 7 - Tester l'accès localement

### Test avec curl

```bash
curl http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

**Résultat attendu:** Code HTML de la page dashboard

### Test santé du proxy

```bash
curl http://localhost:8001/healthz
```

**Résultat attendu:**

```
ok
```

---

## Utilisation du Dashboard

### Navigation dans l'interface

**Menu principal (gauche):**

- **Workloads** : Deployments, Pods, StatefulSets, DaemonSets, Jobs
- **Service** : Services, Ingresses, Endpoints
- **Config and Storage** : ConfigMaps, Secrets, PersistentVolumeClaims
- **Cluster** : Nodes, Namespaces, Events

### Visualiser MySQL

1. Cliquer sur **Namespaces** (en haut) → Sélectionner `mysql-app`
2. Aller dans **Workloads** → **StatefulSets** → Voir `mysql`
3. Cliquer sur `mysql` pour voir les détails
4. Cliquer sur **Pods** → Voir `mysql-0`
5. Dans les détails du pod:
   - **Logs** : Voir les logs MySQL
   - **Exec** : Ouvrir un shell dans le container

### Voir les logs d'un pod

1. Workloads → Pods
2. Sélectionner namespace `mysql-app`
3. Cliquer sur le pod `mysql-0`
4. Cliquer sur l'icône 📋 **Logs**

### Exécuter des commandes dans un pod

1. Workloads → Pods → mysql-0
2. Cliquer sur l'icône 🖥️ **Exec**
3. Une console s'ouvre, taper:

```bash
mysql -uroot -pMySecureP@ssw0rd2024!
```

### Voir les métriques (CPU/Memory)

1. Cluster → Nodes
2. Voir utilisation CPU/Memory des nodes
3. Workloads → Pods → mysql-app namespace
4. Voir utilisation par pod

### Éditer une ressource

1. Trouver la ressource (ex: ConfigMap)
2. Cliquer sur les 3 points ⋮
3. Sélectionner **Edit**
4. Modifier le YAML
5. **Update**

---

## Méthodes alternatives d'accès

### Méthode 1 : minikube dashboard (Auto-open)

```bash
minikube dashboard
```

**Avantage :** Ouvre automatiquement dans le navigateur **Inconvénient :** Seulement en local (pas d'accès distant)

### Méthode 2 : minikube dashboard avec URL

```bash
minikube dashboard --url
```

**Résultat:**

```
http://127.0.0.1:xxxxx/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

Pour accès distant, créer tunnel SSH depuis votre machine locale:

```bash
ssh -L 8001:localhost:xxxxx ubuntu@VOTRE_IP
```

---

## Commandes utiles

### Voir status dashboard

```bash
kubectl get all -n kubernetes-dashboard
```

### Voir logs dashboard

```bash
kubectl logs -n kubernetes-dashboard -l k8s-app=kubernetes-dashboard
```

### Redémarrer dashboard

```bash
kubectl rollout restart deployment kubernetes-dashboard -n kubernetes-dashboard
```

### Vérifier proxy actif

```bash
ps aux | grep "kubectl proxy"
```

### Arrêter le proxy

```bash
pkill -f "kubectl proxy"
```

### Relancer le proxy

```bash
kubectl proxy --address='0.0.0.0' --accept-hosts='.*' --port=8001 &
```

---

## Troubleshooting

### Dashboard ne charge pas dans le navigateur

**1. Vérifier que le proxy tourne**

```bash
ps aux | grep "kubectl proxy"
```

Si absent, relancer:

```bash
kubectl proxy --address='0.0.0.0' --accept-hosts='.*' --port=8001 &
```

**2. Vérifier firewall/security group**

- Port 8001 doit être ouvert
- Tester avec curl localement:

```bash
curl http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

**3. Vérifier les pods dashboard**

```bash
kubectl get pods -n kubernetes-dashboard
```

Si pas Running:

```bash
kubectl describe pod -n kubernetes-dashboard -l k8s-app=kubernetes-dashboard
```

### Erreur "Unable to connect"

**Vérifier l'URL:**

- Utiliser `http://` (pas https)
- Inclure le `/` final
- Vérifier l'IP correcte

**Tester en local d'abord:**

```bash
curl http://localhost:8001/healthz
```

### Proxy killed automatiquement

**Lancer en arrière-plan persistant:**

```bash
nohup kubectl proxy --address='0.0.0.0' --accept-hosts='.*' --port=8001 > /dev/null 2>&1 &
```

### Port 8001 déjà utilisé

**Voir quel processus utilise le port:**

```bash
lsof -i :8001
```

**Tuer le processus:**

```bash
kill $(lsof -t -i:8001)
```

**Ou utiliser un autre port:**

```bash
kubectl proxy --address='0.0.0.0' --accept-hosts='.*' --port=8002 &
```

URL devient:

```
http://VOTRE_IP:8002/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

### Dashboard vide ou erreurs

**Vérifier metrics-server:**

```bash
kubectl get deployment metrics-server -n kube-system
```

Si absent:

```bash
minikube addons enable metrics-server
```

Attendre 1-2 minutes puis rafraîchir le dashboard.

---

## Sécurité

### ⚠️ Important

**kubectl proxy donne accès complet au cluster** (équivalent cluster-admin)

**Recommandations:**

1. **NE PAS exposer sur Internet** sans protection
2. Limiter l'accès au port 8001 à votre IP uniquement dans le security group
3. Utiliser un VPN pour accès distant
4. Arrêter le proxy quand non utilisé:

```bash
pkill -f "kubectl proxy"
```

**Pour production:**

- Ne pas utiliser kubectl proxy
- Utiliser authentification OIDC
- Mettre derrière reverse proxy avec auth (nginx + oauth2-proxy)
- Utiliser Ingress avec TLS

---

## Désinstallation

### Arrêter le proxy

```bash
pkill -f "kubectl proxy"
```

### Désactiver l'addon

```bash
minikube addons disable dashboard
minikube addons disable metrics-server
```

### Vérifier

```bash
minikube addons list | grep -E "dashboard|metrics-server"
```

**Résultat attendu:**

```
| dashboard                   | minikube | disabled ❌   | Kubernetes        |
| metrics-server              | minikube | disabled ❌   | Kubernetes        |
```

---

## Résumé des commandes

```bash
# 1. Activer addons
minikube addons enable dashboard
minikube addons enable metrics-server

# 2. Attendre pods ready
kubectl wait --for=condition=ready pod -l k8s-app=kubernetes-dashboard -n kubernetes-dashboard --timeout=120s

# 3. Lancer proxy
kubectl proxy --address='0.0.0.0' --accept-hosts='.*' --port=8001 &

# 4. Ajouter exception firewall port 8001

# 5. Accéder au dashboard
# http://VOTRE_IP:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

---

## Points clés à retenir

1. **Addons Minikube** : dashboard + metrics-server
2. **kubectl proxy** : Nécessaire pour accès distant
3. **Port 8001** : Exception firewall obligatoire
4. **Pas de login** : Accès direct via proxy (pas de token requis)
5. **URL complète** : Ne pas oublier le path complet avec `/proxy/`
6. **Sécurité** : Limiter l'accès, ne pas exposer publiquement
