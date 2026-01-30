# Kubernetes Dashboard - Installation Minikube

## Installation

```bash
chmod +x install-k8s-dashboard.sh
./install-k8s-dashboard.sh
```

Le script va:
1. Activer l'addon dashboard Minikube
2. Activer metrics-server
3. Créer un utilisateur admin
4. Générer un token d'accès
5. Configurer un service NodePort

## Accès au Dashboard

### Méthode kubectl proxy (RECOMMANDÉ - Fonctionne sur EC2)

```bash
# 1. Lancer kubectl proxy sur toutes les interfaces
kubectl proxy --address='0.0.0.0' --accept-hosts='.*' --port=8001 &

# 2. Ajouter exception firewall port 8001

# 3. Accéder dans le navigateur
# http://VOTRE_IP:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

**⚠️ IMPORTANT:**
- Utiliser `http:` (pas https)
- Ajouter exception firewall/security group port 8001
- Le proxy doit rester actif en background

**URL complète exemple:**
```
http://13.60.25.74:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

### Méthode minikube dashboard (Alternative - local)

```bash
# Génère une URL locale
minikube dashboard --url=true

# Pour accès distant, créer tunnel SSH depuis votre machine:
# ssh -L 8001:localhost:XXXXX ubuntu@VOTRE_IP
```

## Pas de Login requis

Avec kubectl proxy, l'authentification est automatique via le proxy.
Le dashboard s'affiche directement sans token.

## Vérifications

```bash
# Status pods dashboard
kubectl get pods -n kubernetes-dashboard

# Vérifier que le proxy tourne
ps aux | grep "kubectl proxy"

# Tester en local
curl http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/

# Si le proxy est arrêté, relancer:
kubectl proxy --address='0.0.0.0' --accept-hosts='.*' --port=8001 &
```

## Fonctionnalités Dashboard

### Vue d'ensemble
- **Workloads**: Deployments, StatefulSets, Pods, Jobs
- **Services**: Services, Ingress, Endpoints
- **Config**: ConfigMaps, Secrets, PVC
- **Cluster**: Nodes, Namespaces, Events

### Actions possibles
- Voir les logs des pods
- Accéder au shell des conteneurs
- Éditer les ressources (YAML)
- Scaler les deployments
- Supprimer des ressources

### Pour MySQL

```
1. Cluster → Namespaces → mysql-app
2. Workloads → StatefulSets → mysql
3. Click sur "mysql-0" pour voir détails
4. Onglet "Logs" pour les logs
5. Onglet "Exec" pour shell interactif
```

## Exemples d'utilisation

### Voir logs MySQL

```
Workloads → Pods → mysql-app namespace → mysql-0 → Logs
```

### Shell dans MySQL

```
Workloads → Pods → mysql-app namespace → mysql-0 → Exec
# Dans le shell:
mysql -uroot -pMySecureP@ssw0rd2024!
```

### Vérifier utilisation ressources

```
Cluster → Nodes → Voir CPU/Memory
Workloads → Pods → mysql-app → Voir utilisation par pod
```

### Éditer configuration

```
Config and Storage → Config Maps → mysql-app → mysql-init-script → Edit
```

## Troubleshooting

### Dashboard ne démarre pas

```bash
# Vérifier addon
minikube addons list | grep dashboard

# Si désactivé, réactiver
minikube addons enable dashboard

# Attendre pods
kubectl wait --for=condition=ready pod -l k8s-app=kubernetes-dashboard -n kubernetes-dashboard --timeout=120s
```

### Proxy ne fonctionne pas

```bash
# Vérifier qu'il tourne
ps aux | grep "kubectl proxy"

# Tuer et relancer
pkill -f "kubectl proxy"
kubectl proxy --address='0.0.0.0' --accept-hosts='.*' --port=8001 &

# Vérifier le port
netstat -tuln | grep 8001
```

### Dashboard inaccessible depuis navigateur

1. **Vérifier firewall/security group AWS**: Port 8001 ouvert
2. **Vérifier proxy**: `ps aux | grep kubectl`
3. **Tester en local**: `curl localhost:8001`
4. **URL correcte**: Utiliser `http:` pas `https:`

### Port 8001 déjà utilisé

```bash
# Voir qui utilise le port
lsof -i :8001

# Utiliser un autre port
kubectl proxy --address='0.0.0.0' --accept-hosts='.*' --port=8002 &
# URL: http://VOTRE_IP:8002/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

## Sécurité

**⚠️ IMPORTANT:**
- kubectl proxy donne accès **complet au cluster** (équivalent cluster-admin)
- **NE PAS exposer sur Internet** sans VPN/Firewall strict
- Limiter l'accès au port 8001 à votre IP uniquement dans le security group

**Pour production:**
- Utiliser un reverse proxy avec authentification (nginx, oauth2-proxy)
- Activer l'authentification OIDC sur le cluster
- Ne pas utiliser kubectl proxy en production
- Utiliser Ingress avec TLS et authentification

## Désinstallation

```bash
# Arrêter le proxy
pkill -f "kubectl proxy"

# Désactiver addon
minikube addons disable dashboard
minikube addons disable metrics-server
```

## Alternatives

### K9s (CLI Dashboard)

```bash
# Installation
curl -sS https://webinstall.dev/k9s | bash

# Lancer
k9s
```

Navigation:
- `:pod` → Liste pods
- `:svc` → Liste services
- `:deploy` → Liste deployments
- `l` → Logs
- `s` → Shell
- `d` → Describe

### Lens (Desktop App)

Télécharger: https://k8slens.dev/

Application graphique complète pour gérer Kubernetes.

## Ressources

- [Dashboard officiel](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
- [GitHub Kubernetes Dashboard](https://github.com/kubernetes/dashboard)
