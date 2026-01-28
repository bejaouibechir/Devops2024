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
echo -e "${YELLOW}Suppression du namespace mysql-app...${NC}"
kubectl delete namespace mysql-app --timeout=60s 2>/dev/null
echo -e "${GREEN}✓ Namespace mysql-app supprimé${NC}"

echo ""
echo -e "${YELLOW}Désinstallation de Prometheus/Grafana...${NC}"
helm uninstall prometheus -n monitoring 2>/dev/null
echo -e "${GREEN}✓ Prometheus/Grafana désinstallés${NC}"

echo ""
echo -e "${YELLOW}Suppression du namespace monitoring...${NC}"
kubectl delete namespace monitoring --timeout=60s 2>/dev/null
echo -e "${GREEN}✓ Namespace monitoring supprimé${NC}"

echo ""
echo -e "${YELLOW}Suppression du Dashboard Kubernetes...${NC}"
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml 2>/dev/null
kubectl delete clusterrolebinding admin-user 2>/dev/null
kubectl delete serviceaccount admin-user -n kubernetes-dashboard 2>/dev/null
echo -e "${GREEN}✓ Dashboard supprimé${NC}"

echo ""
echo -e "${YELLOW}Suppression des CRDs Prometheus...${NC}"
kubectl delete crd prometheuses.monitoring.coreos.com 2>/dev/null
kubectl delete crd prometheusrules.monitoring.coreos.com 2>/dev/null
kubectl delete crd servicemonitors.monitoring.coreos.com 2>/dev/null
kubectl delete crd podmonitors.monitoring.coreos.com 2>/dev/null
kubectl delete crd alertmanagers.monitoring.coreos.com 2>/dev/null
kubectl delete crd alertmanagerconfigs.monitoring.coreos.com 2>/dev/null
kubectl delete crd thanosrulers.monitoring.coreos.com 2>/dev/null
kubectl delete crd probes.monitoring.coreos.com 2>/dev/null
echo -e "${GREEN}✓ CRDs supprimés${NC}"

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
echo "Pour redémarrer l'atelier, exécutez:"
echo "  ./scripts/deploy-all.sh"
