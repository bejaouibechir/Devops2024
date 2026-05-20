#!/bin/bash

# Script de monitoring en temps réel
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

while true; do
  clear
  echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║   Kubernetes MySQL Workshop - Monitoring Dashboard        ║${NC}"
  echo -e "${GREEN}║   $(date +'%Y-%m-%d %H:%M:%S')                                      ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  
  echo -e "${YELLOW}━━━ Pods Status ━━━${NC}"
  kubectl get pods -n mysql-app -o wide 2>/dev/null || echo "Namespace mysql-app non trouvé"
  echo ""
  
  echo -e "${YELLOW}━━━ Services ━━━${NC}"
  kubectl get svc -n mysql-app 2>/dev/null
  echo ""
  
  echo -e "${YELLOW}━━━ HPA Status ━━━${NC}"
  kubectl get hpa -n mysql-app 2>/dev/null || echo "HPA non configuré ou pas de métriques"
  echo ""
  
  echo -e "${YELLOW}━━━ Resource Usage ━━━${NC}"
  kubectl top pods -n mysql-app 2>/dev/null || echo "⚠ Métriques non disponibles (metrics-server requis)"
  echo ""
  
  echo -e "${YELLOW}━━━ Recent Events (last 5) ━━━${NC}"
  kubectl get events -n mysql-app --sort-by='.lastTimestamp' 2>/dev/null | tail -6
  echo ""
  
  echo -e "${BLUE}━━━ PersistentVolumeClaims ━━━${NC}"
  kubectl get pvc -n mysql-app 2>/dev/null
  echo ""
  
  echo -e "${GREEN}[Ctrl+C pour quitter | Rafraîchissement toutes les 10s]${NC}"
  
  sleep 10
done
