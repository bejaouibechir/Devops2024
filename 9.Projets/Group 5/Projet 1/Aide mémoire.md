# Guide de Référence Rapide

## Démarrage Rapide

```bash
# 1. Déploiement complet
./scripts/deploy-all.sh

# 2. Accéder aux interfaces
# Dashboard K8s:  kubectl proxy → http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
# Grafana:        kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 → http://localhost:3000
# API Flask:      kubectl port-forward -n mysql-app svc/flask-backend 5000:5000 → http://localhost:5000

# 3. Tester l'API
./scripts/test-api.sh

# 4. Monitoring
./scripts/monitor.sh

# 5. Nettoyage
./scripts/cleanup.sh
```

## Commandes Essentielles

### Visualisation

```bash
# Tous les pods
kubectl get pods -n mysql-app

# Tous les objets dans le namespace
kubectl get all -n mysql-app

# État détaillé d'un pod
kubectl describe pod <pod-name> -n mysql-app

# Logs en temps réel
kubectl logs -f <pod-name> -n mysql-app

# Métriques
kubectl top pods -n mysql-app
kubectl top nodes
```

### Accès aux Services

```bash
# Port-forward MySQL
kubectl port-forward -n mysql-app svc/mysql-service 3306:3306

# Port-forward Flask
kubectl port-forward -n mysql-app svc/flask-backend 5000:5000

# Port-forward Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Port-forward Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

### Debugging

```bash
# Shell dans MySQL
kubectl exec -it -n mysql-app mysql-0 -- bash

# MySQL client
kubectl exec -it -n mysql-app mysql-0 -- mysql -uroot -p

# Shell dans Flask
kubectl exec -it -n mysql-app deployment/flask-backend -- sh

# Événements récents
kubectl get events -n mysql-app --sort-by='.lastTimestamp' | tail -20
```

### Scaling

```bash
# Scaler le backend
kubectl scale deployment flask-backend -n mysql-app --replicas=5

# Voir le HPA
kubectl get hpa -n mysql-app

# Désactiver le HPA
kubectl delete hpa flask-backend-hpa -n mysql-app

# Réactiver le HPA
kubectl apply -f backend/k8s/04-hpa.yaml
```

## Secrets et Mots de Passe

### MySQL

- Root password: `MySecureP@ssw0rd2024!`
- App user: `appuser`
- App password: `AppU5er@2024`
- Database: `businessdb`

### Grafana

```bash
# Obtenir le mot de passe admin
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
# Username: admin
```

### Dashboard Kubernetes

```bash
# Obtenir le token d'accès
kubectl -n kubernetes-dashboard create token admin-user
```

## Endpoints API Flask

```bash
BASE_URL="http://localhost:5000"

# Health check
curl $BASE_URL/health | jq

# Liste des employés
curl $BASE_URL/employees | jq

# Employé spécifique
curl $BASE_URL/employees/1 | jq

# Créer un employé
curl -X POST $BASE_URL/employees \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","address":"123 Main St","salary":50000,"department":"IT"}' | jq

# Mettre à jour
curl -X PUT $BASE_URL/employees/1 \
  -H "Content-Type: application/json" \
  -d '{"salary":55000}' | jq

# Supprimer
curl -X DELETE $BASE_URL/employees/1 | jq

# Statistiques
curl $BASE_URL/stats | jq

# Pagination
curl "$BASE_URL/employees?page=1&per_page=5" | jq

# Filtrer par département
curl "$BASE_URL/employees?department=IT" | jq
```

## Tests de Charge

```bash
# Avec K6
k6 run scripts/load-test.js

# Avec curl en boucle
for i in {1..100}; do
  curl -s $BASE_URL/employees > /dev/null
  echo "Request $i completed"
  sleep 0.1
done
```

## Dashboards Grafana Recommandés

Importer ces dashboards par ID:

- **7362**: MySQL Overview
- **6417**: Kubernetes Cluster Monitoring
- **13770**: Kubernetes Pods Monitoring
- **1860**: Node Exporter Full

## Redéploiement Rapide

```bash
# MySQL uniquement
kubectl delete statefulset mysql -n mysql-app
kubectl apply -f mysql/03-statefulset.yaml

# Backend uniquement
kubectl delete deployment flask-backend -n mysql-app
# Reconstruire l'image si nécessaire
cd backend/src && docker build -t mysql-flask-backend:1.0 . && cd ../..
minikube image load mysql-flask-backend:1.0
kubectl apply -f backend/k8s/02-deployment.yaml

# Monitoring uniquement
helm uninstall prometheus -n monitoring
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

## Résolution de Problèmes Rapide

### Pod en CrashLoopBackOff

```bash
kubectl describe pod <pod-name> -n mysql-app
kubectl logs <pod-name> -n mysql-app --previous
```

### Image non trouvée

```bash
# Vérifier les images dans Minikube
minikube image ls | grep mysql-flask

# Recharger l'image
minikube image load mysql-flask-backend:1.0
```

### PVC en Pending

```bash
kubectl describe pvc <pvc-name> -n mysql-app
# Vérifier le storageClass
kubectl get storageclass
```

### Service non accessible

```bash
# Vérifier les endpoints
kubectl get endpoints -n mysql-app

# Vérifier les labels
kubectl get pods -n mysql-app --show-labels
```

## Structure des Fichiers

```
k8s-workshop/
├── README.md                    # Documentation principale
├── ATELIER_KUBERNETES_MYSQL.md # Guide de l'atelier
├── QUICK_REFERENCE.md          # Ce fichier
├── mysql/                      # Manifests MySQL
│   ├── 00-namespace.yaml
│   ├── 01-secret.yaml
│   ├── 02-configmap.yaml
│   ├── 03-statefulset.yaml
│   └── 04-services.yaml
├── backend/                    # Application Flask
│   ├── src/
│   │   ├── app.py
│   │   ├── requirements.txt
│   │   └── Dockerfile
│   └── k8s/
│       ├── 01-secret.yaml
│       ├── 02-deployment.yaml
│       ├── 03-service.yaml
│       └── 04-hpa.yaml
├── monitoring/                 # Monitoring
│   ├── mysql-exporter.yaml
│   └── prometheus-rules.yaml
└── scripts/                    # Scripts utilitaires
    ├── deploy-all.sh
    ├── test-api.sh
    ├── load-test.js
    ├── monitor.sh
    └── cleanup.sh
```

## Checklist de Vérification

- [ ] Minikube démarré avec bonnes ressources
- [ ] MySQL pod en état Running et Ready
- [ ] PVC mysql-data-mysql-0 bound
- [ ] Flask pods (3) en état Running et Ready
- [ ] Services accessibles via port-forward
- [ ] Prometheus et Grafana installés
- [ ] MySQL Exporter collecte les métriques
- [ ] Dashboard Kubernetes accessible
- [ ] Tests API passent avec succès
- [ ] HPA fonctionne correctement

## 🔗 Liens Utiles

- Minikube Dashboard: `minikube dashboard`
- Voir les addons: `minikube addons list`
- IP du cluster: `minikube ip`
- SSH dans le nœud: `minikube ssh`

## Astuces

```bash
# Alias utiles à ajouter dans ~/.bashrc
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kl='kubectl logs'
alias kex='kubectl exec -it'

# Autocomplétion kubectl
source <(kubectl completion bash)
```

# Aide mémoire GitLab Registry et images Docker

## A) Règles simples à respecter

1. Une image Docker publiée dans GitLab a un nom de type :
   - registry GitLab + chemin du projet + nom image
2. Le tag recommandé est :
   - hash commit (immuable)
3. Le tag latest est :
   - pratique, mais non traçable seul

## B) Authentification Registry côté pipeline

Objectif :

- Le pipeline doit pouvoir pousser.

Principe :

- GitLab fournit des variables intégrées pour s’authentifier au Registry dans le job build/push.

Résultat attendu :

- Le push fonctionne à chaque pipeline.

---

## C) Pull d’image depuis Kubernetes

Cas important : un cluster Kubernetes qui tire une image depuis un registry privé a besoin d’un secret de type docker registry.

1. Créer un secret Kubernetes image pull avec :
   
   - registry GitLab
   
   - un compte technique : deploy token GitLab ou user robot

2. Référencer ce secret dans :
   
   - imagePullSecrets du Deployment
   
   - ou ServiceAccount du namespace

Résultat attendu :

- Les pods backend démarrent sans ImagePullBackOff.

---

# Variables GitLab CI à définir

## 1) Variables SSH vers EC2

- EC2_HOST : IP ou DNS

- EC2_USER : utilisateur SSH

- EC2_SSH_PRIVATE_KEY : clé privée

- EC2_SSH_KNOWN_HOSTS : empreinte ou known_hosts pré-rempli

Bonnes pratiques :

- Variables en mode masked

- Variables en mode protected si déploiement production

---

## 2) Variables Kubernetes

Selon ton choix :

Option kubeconfig stocké dans GitLab

- KUBECONFIG_CONTENT : contenu kubeconfig encodé

- KUBE_CONTEXT_NAME : contexte à sélectionner

Option kubeconfig stocké sur EC2

- KUBECONFIG_PATH : chemin local sur EC2

- KUBE_CONTEXT_NAME : contexte (optionnel)

---

## 3) Variables applicatives

- APP_NAMESPACE

- MYSQL_ROOT_PASSWORD

- MYSQL_DATABASE

- MYSQL_USER

- MYSQL_PASSWORD

---

## 4) Variables images

- BACKEND_IMAGE_NAME : nom complet de l’image

- BACKEND_IMAGE_TAG : tag commit ou tag choisi

---

# Déploiement vers EC2 : séquence attendue côté apprenant

## Étape 1 – Lancer un pipeline

1. Pousser un commit.

2. Vérifier que le pipeline passe Stage A, B, C.

Résultat attendu :

- L’image est publiée dans le Registry.

---

## Étape 2 – Déploiement automatique sur EC2

1. Le job deploy se connecte à EC2 ou s’exécute sur EC2.

2. Le job exécute le script de déploiement.

3. Le job applique les manifests avec la bonne image et le bon tag.

Résultat attendu :

- Pods MySQL et backend en état Ready.

---

## Étape 3 – Tests automatiques

1. Exécuter le script de test API.

2. Exécuter le script de charge (optionnel).

3. Exécuter le script de validation monitoring (si monitoring activé).

Résultat attendu :

- Tests OK et preuves visibles dans les logs du job.

---

# Pièges à éviter

1. Image non trouvée
- Cause : image non push ou mauvais tag

- Symptôme : ImagePullBackOff
2. Registry privé sans image pull secret
- Cause : pas de secret docker registry côté Kubernetes

- Symptôme : pull denied
3. SSH instable
- Cause : known_hosts absent ou clé non chargée correctement

- Symptôme : job bloqué ou refus connexion
4. Variables non protégées
- Cause : variables sensibles accessibles depuis branches non protégées

- Risque : fuite de secrets

---

# Liaison avec la suite

Étape suivante logique :

- Ajouter un mode déploiement par environnement :
  
  - dev, staging, prod

- Ajouter une approbation manuelle pour prod

- Ajouter une stratégie rollback automatique si tests échouent
