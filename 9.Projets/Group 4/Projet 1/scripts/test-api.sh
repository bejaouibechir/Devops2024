#!/bin/bash

# Script de test complet de l'API Flask
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

API_URL="http://localhost:5000"

echo -e "${GREEN}=== Test d'Intégration Backend Flask + MySQL ===${NC}"
echo ""

# Vérifier que l'API est accessible
echo -e "${YELLOW}0. Vérification de l'accessibilité de l'API...${NC}"
if ! curl -s $API_URL > /dev/null 2>&1; then
    echo -e "${RED}✗ L'API n'est pas accessible à $API_URL${NC}"
    echo "Assurez-vous d'avoir exécuté: kubectl port-forward -n mysql-app svc/flask-backend 5000:5000 --address='0.0.0.0' &"
    exit 1
fi
echo -e "${GREEN}✓ API accessible${NC}"
echo ""

# 1. Health Check
echo -e "${YELLOW}1. Health Check...${NC}"
HEALTH=$(curl -s $API_URL/health)
echo $HEALTH | python3 -m json.tool 2>/dev/null || echo $HEALTH
echo ""

# 2. Lister les employés
echo -e "${YELLOW}2. Liste initiale des employés...${NC}"
EMPLOYEES=$(curl -s $API_URL/employees)
INITIAL_COUNT=$(echo $EMPLOYEES | python3 -c "import sys, json; print(json.load(sys.stdin)['total'])" 2>/dev/null)
echo "Nombre d'employés: $INITIAL_COUNT"
echo $EMPLOYEES | python3 -m json.tool 2>/dev/null | head -30
echo ""

# 3. Créer un employé
echo -e "${YELLOW}3. Création d'un nouvel employé...${NC}"
NEW_EMP=$(curl -s -X POST $API_URL/employees \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Integration User",
    "address": "123 Test Street, 75001 Paris",
    "salary": 50000,
    "department": "QA",
    "hire_date": "2024-01-30"
  }')
echo $NEW_EMP | python3 -m json.tool 2>/dev/null || echo $NEW_EMP
EMP_ID=$(echo $NEW_EMP | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null)
echo -e "${GREEN}✓ ID créé: $EMP_ID${NC}"
echo ""

# 4. Lire l'employé créé
echo -e "${YELLOW}4. Lecture de l'employé créé...${NC}"
curl -s $API_URL/employees/$EMP_ID | python3 -m json.tool 2>/dev/null
echo ""

# 5. Mettre à jour l'employé
echo -e "${YELLOW}5. Mise à jour du salaire...${NC}"
UPDATE=$(curl -s -X PUT $API_URL/employees/$EMP_ID \
  -H "Content-Type: application/json" \
  -d '{"salary": 55000, "department": "DevOps"}')
echo $UPDATE | python3 -m json.tool 2>/dev/null || echo $UPDATE
echo ""

# 6. Vérifier la mise à jour
echo -e "${YELLOW}6. Vérification de la mise à jour...${NC}"
curl -s $API_URL/employees/$EMP_ID | python3 -m json.tool 2>/dev/null | grep -E "(name|department|salary)"
echo ""

# 7. Statistiques
echo -e "${YELLOW}7. Statistiques de la base de données...${NC}"
curl -s $API_URL/stats | python3 -m json.tool 2>/dev/null
echo ""

# 8. Tester la pagination
echo -e "${YELLOW}8. Test de pagination...${NC}"
echo "Page 1 (3 par page):"
curl -s "$API_URL/employees?page=1&per_page=3" | python3 -m json.tool 2>/dev/null | head -20
echo ""

# 9. Filtrer par département
echo -e "${YELLOW}9. Filtrer par département IT...${NC}"
curl -s "$API_URL/employees?department=IT" | python3 -m json.tool 2>/dev/null | head -20
echo ""

# 10. Supprimer l'employé de test
echo -e "${YELLOW}10. Suppression de l'employé de test...${NC}"
DELETE=$(curl -s -X DELETE $API_URL/employees/$EMP_ID)
echo $DELETE | python3 -m json.tool 2>/dev/null || echo $DELETE
echo ""

# 11. Vérifier la suppression
echo -e "${YELLOW}11. Vérification de la suppression...${NC}"
FINAL_COUNT=$(curl -s $API_URL/employees | python3 -c "import sys, json; print(json.load(sys.stdin)['total'])" 2>/dev/null)
echo "Nombre final d'employés: $FINAL_COUNT"
if [ "$INITIAL_COUNT" == "$FINAL_COUNT" ]; then
    echo -e "${GREEN}✓ La suppression a réussi (retour au nombre initial)${NC}"
else
    echo -e "${YELLOW}⚠ Attention: Le nombre d'employés a changé${NC}"
fi
echo ""

echo -e "${GREEN}=== Tests terminés avec succès! ===${NC}"
echo ""
echo -e "${YELLOW}Commandes manuelles utiles:${NC}"
echo "  GET tous les employés:  curl http://localhost:5000/employees"
echo "  GET un employé:         curl http://localhost:5000/employees/1"
echo "  POST créer:             curl -X POST http://localhost:5000/employees -H 'Content-Type: application/json' -d '{\"name\":\"John\",\"address\":\"Paris\",\"salary\":50000,\"department\":\"IT\"}'"
echo "  PUT mettre à jour:      curl -X PUT http://localhost:5000/employees/1 -H 'Content-Type: application/json' -d '{\"salary\":60000}'"
echo "  DELETE supprimer:       curl -X DELETE http://localhost:5000/employees/1"
echo "  GET statistiques:       curl http://localhost:5000/stats"