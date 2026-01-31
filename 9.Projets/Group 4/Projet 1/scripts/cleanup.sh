#!/bin/bash

# Script de nettoyage complet
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  Nettoyage de l'atelier Kubernetes    ${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

read -p "Êtes-vous sûr de vouloir tout supprimer? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Annulation du nettoyage."
    exit 1
fi

echo ""
echo -e "${YELLOW}Suppression du backend Flask...${NC}"
kubectl delete -f backend/k8s/04-hpa.yaml 2>/dev/null || true
kubectl delete -f backend/k8s/03-service.yaml 2>/dev/null || true
kubectl delete -f backend/k8s/02-deployment.yaml 2>/dev/null || true
kubectl delete -f backend/k8s/01-secret.yaml 2>/dev/null || true
echo -e "${GREEN}✓ Backend supprimé${NC}"

echo ""
echo -e "${YELLOW}Suppression de MySQL...${NC}"
kubectl delete -f mysql/04-services.yaml 2>/dev/null || true
kubectl delete -f mysql/03-statefulset.yaml 2>/dev/null || true
kubectl delete -f mysql/02-configmap.yaml 2>/dev/null || true
kubectl delete -f mysql/01-secret.yaml 2>/dev/null || true
kubectl delete pvc -n mysql-app --all 2>/dev/null || true
kubectl delete -f mysql/00-namespace.yaml 2>/dev/null || true
echo -e "${GREEN}✓ MySQL supprimé${NC}"

echo ""
echo -e "${YELLOW}Suppression du monitoring...${NC}"
kubectl delete namespace monitoring --timeout=60s 2>/dev/null || true
kubectl delete clusterrolebinding prometheus 2>/dev/null || true
kubectl delete clusterrole prometheus 2>/dev/null || true
echo -e "${GREEN}✓ Monitoring supprimé${NC}"

echo ""
echo -e "${YELLOW}Arrêt des port-forwards...${NC}"
pkill -f "port-forward" 2>/dev/null || true
pkill -f "kubectl proxy" 2>/dev/null || true
echo -e "${GREEN}✓ Port-forwards arrêtés${NC}"

echo ""
read -p "Voulez-vous arrêter Minikube? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo -e "${YELLOW}Arrêt de Minikube...${NC}"
    minikube stop
    echo -e "${GREEN}✓ Minikube arrêté${NC}"
fi

echo ""
read -p "Voulez-vous supprimer complètement le cluster Minikube? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo -e "${RED}Suppression complète de Minikube...${NC}"
    minikube delete
    echo -e "${GREEN}✓ Minikube supprimé${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Nettoyage terminé!                   ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Pour redémarrer l'atelier, suivez les README:"
echo "  - MySQL: mysql/README.md"
echo "  - Backend: backend/README.md"
echo "  - Monitoring: monitoring/README-MONITORING-MINIMAL.md"