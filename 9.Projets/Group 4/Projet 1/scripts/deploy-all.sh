#!/bin/bash

# Script de déploiement complet de l'atelier Kubernetes MySQL
# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Déploiement Atelier Kubernetes MySQL ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Fonction pour afficher un message de succès
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Fonction pour afficher un message d'erreur
error() {
    echo -e "${RED}✗ $1${NC}"
}

# Fonction pour afficher un message d'information
info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Vérifier que Minikube est démarré
info "Vérification de Minikube..."
if ! minikube status > /dev/null 2>&1; then
    error "Minikube n'est pas démarré. Lancement en cours..."
    minikube start --cpus=4 --memory=8192 --disk-size=20g
    if [ $? -eq 0 ]; then
        success "Minikube démarré avec succès"
    else
        error "Impossible de démarrer Minikube"
        exit 1
    fi
else
    success "Minikube est en cours d'exécution"
fi

# Activer les addons nécessaires
info "Activation des addons Minikube..."
minikube addons enable metrics-server
minikube addons enable storage-provisioner
success "Addons activés"

echo ""
echo -e "${YELLOW}=== Étape 1: Déploiement MySQL ===${NC}"

# Déployer MySQL
info "Application des manifests MySQL..."
kubectl apply -f mysql/00-namespace.yaml
sleep 2
kubectl apply -f mysql/01-secret.yaml
kubectl apply -f mysql/02-configmap.yaml
kubectl apply -f mysql/03-statefulset.yaml
kubectl apply -f mysql/04-services.yaml

# Attendre que MySQL soit prêt
info "Attente du démarrage de MySQL (cela peut prendre 2-3 minutes)..."
kubectl wait --for=condition=ready pod/mysql-0 -n mysql-app --timeout=300s
if [ $? -eq 0 ]; then
    success "MySQL est prêt"
else
    error "Timeout lors du démarrage de MySQL"
    exit 1
fi

echo ""
echo -e "${YELLOW}=== Étape 2: Construction et chargement de l'image Flask ===${NC}"

# Construire l'image Docker
info "Construction de l'image Flask..."
cd backend/src
docker build -t mysql-flask-backend:1.0 . > /dev/null 2>&1
if [ $? -eq 0 ]; then
    success "Image construite avec succès"
else
    error "Erreur lors de la construction de l'image"
    exit 1
fi

# Charger l'image dans Minikube
info "Chargement de l'image dans Minikube..."
minikube image load mysql-flask-backend:1.0
success "Image chargée dans Minikube"

cd ../..

echo ""
echo -e "${YELLOW}=== Étape 3: Déploiement du Backend Flask ===${NC}"

info "Application des manifests Backend..."
kubectl apply -f backend/k8s/01-secret.yaml
kubectl apply -f backend/k8s/02-deployment.yaml
kubectl apply -f backend/k8s/03-service.yaml
kubectl apply -f backend/k8s/04-hpa.yaml

# Attendre que le backend soit prêt
info "Attente du démarrage du backend..."
sleep 10
kubectl wait --for=condition=ready pod -l app=flask-backend -n mysql-app --timeout=120s
if [ $? -eq 0 ]; then
    success "Backend Flask est prêt"
else
    error "Timeout lors du démarrage du backend"
    exit 1
fi

echo ""
echo -e "${YELLOW}=== Étape 4: Installation de Prometheus et Grafana ===${NC}"

# Vérifier si Helm est installé
if ! command -v helm &> /dev/null; then
    info "Installation de Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    success "Helm installé"
fi

# Créer le namespace monitoring
kubectl create namespace monitoring 2>/dev/null || true

# Ajouter les repos Helm
info "Ajout des repositories Helm..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts > /dev/null 2>&1
helm repo update > /dev/null 2>&1
success "Repositories Helm ajoutés"

# Installer Prometheus avec Grafana
info "Installation de Prometheus et Grafana (cela peut prendre quelques minutes)..."
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --wait --timeout 10m > /dev/null 2>&1

if [ $? -eq 0 ]; then
    success "Prometheus et Grafana installés"
else
    error "Erreur lors de l'installation de Prometheus/Grafana"
    exit 1
fi

# Déployer MySQL Exporter
info "Déploiement de MySQL Exporter..."
kubectl apply -f monitoring/mysql-exporter.yaml
sleep 5
kubectl apply -f monitoring/prometheus-rules.yaml
success "MySQL Exporter et alertes configurés"

echo ""
echo -e "${YELLOW}=== Étape 5: Installation du Dashboard Kubernetes ===${NC}"

info "Installation du Dashboard..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml > /dev/null 2>&1

# Créer le ServiceAccount admin
info "Création du compte admin..."
cat <<EOF | kubectl apply -f - > /dev/null 2>&1
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

success "Dashboard installé"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Déploiement terminé avec succès! ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Informations utiles:${NC}"
echo ""
echo "📊 Pour accéder au Dashboard Kubernetes:"
echo "   kubectl proxy"
echo "   URL: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
echo ""
echo "   Token d'accès:"
echo "   kubectl -n kubernetes-dashboard create token admin-user"
echo ""
echo "📈 Pour accéder à Grafana:"
echo "   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "   URL: http://localhost:3000"
echo "   Username: admin"
echo "   Password: \$(kubectl get secret -n monitoring prometheus-grafana -o jsonpath=\"{.data.admin-password}\" | base64 --decode)"
echo ""
echo "🔧 Pour accéder à l'API Flask:"
echo "   kubectl port-forward -n mysql-app svc/flask-backend 5000:5000"
echo "   URL: http://localhost:5000"
echo ""
echo "📦 Pods déployés:"
kubectl get pods -n mysql-app
echo ""
echo "🔍 Pour voir tous les services:"
echo "   kubectl get all -n mysql-app"
echo ""
