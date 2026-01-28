#!/bin/bash

# Script de test complet de l'API Flask
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

API_URL="http://localhost:5000"

echo -e "${GREEN}=== Test d'Intégration Backend Flask + MySQL ===${NC}"
echo ""

# Vérifier que l'API est accessible
echo -e "${YELLOW}0. Vérification de l'accessibilité de l'API...${NC}"
if ! curl -s $API_URL > /dev/null 2>&1; then
    echo "❌ L'API n'est pas accessible à $API_URL"
    echo "Assurez-vous d'avoir exécuté: kubectl port-forward -n mysql-app svc/flask-backend 5000:5000"
    exit 1
fi
echo "✓ API accessible"
echo ""

# 1. Health Check
echo -e "${YELLOW}1. Health Check...${NC}"
curl -s $API_URL/health | jq .
echo ""

# 2. Lister les employés
echo -e "${YELLOW}2. Liste initiale des employés...${NC}"
INITIAL_COUNT=$(curl -s $API_URL/employees | jq '.total')
echo "Nombre d'employés: $INITIAL_COUNT"
curl -s $API_URL/employees | jq '.employees[] | {id, name, department, salary}'
echo ""

# 3. Créer un employé
echo -e "${YELLOW}3. Création d'un nouvel employé...${NC}"
NEW_EMP=$(curl -s -X POST $API_URL/employees \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Integration User",
    "address": "123 Test Street, 75001 Paris",
    "salary": 50000,
    "department": "QA"
  }')
echo $NEW_EMP | jq .
EMP_ID=$(echo $NEW_EMP | jq -r '.id')
echo "✓ ID créé: $EMP_ID"
echo ""

# 4. Lire l'employé créé
echo -e "${YELLOW}4. Lecture de l'employé créé...${NC}"
curl -s $API_URL/employees/$EMP_ID | jq .
echo ""

# 5. Mettre à jour l'employé
echo -e "${YELLOW}5. Mise à jour du salaire...${NC}"
curl -s -X PUT $API_URL/employees/$EMP_ID \
  -H "Content-Type: application/json" \
  -d '{"salary": 55000, "department": "DevOps"}' | jq .
echo ""

# 6. Vérifier la mise à jour
echo -e "${YELLOW}6. Vérification de la mise à jour...${NC}"
UPDATED=$(curl -s $API_URL/employees/$EMP_ID | jq '{name, department, salary}')
echo $UPDATED
echo ""

# 7. Statistiques
echo -e "${YELLOW}7. Statistiques de la base de données...${NC}"
curl -s $API_URL/stats | jq .
echo ""

# 8. Tester la pagination
echo -e "${YELLOW}8. Test de pagination...${NC}"
echo "Page 1 (3 par page):"
curl -s "$API_URL/employees?page=1&per_page=3" | jq '{total, page, total_pages, employees: [.employees[] | {id, name}]}'
echo ""

# 9. Filtrer par département
echo -e "${YELLOW}9. Filtrer par département IT...${NC}"
curl -s "$API_URL/employees?department=IT" | jq '{total, employees: [.employees[] | {id, name, department}]}'
echo ""

# 10. Supprimer l'employé de test
echo -e "${YELLOW}10. Suppression de l'employé de test...${NC}"
curl -s -X DELETE $API_URL/employees/$EMP_ID | jq .
echo ""

# 11. Vérifier la suppression
echo -e "${YELLOW}11. Vérification de la suppression...${NC}"
FINAL_COUNT=$(curl -s $API_URL/employees | jq '.total')
echo "Nombre final d'employés: $FINAL_COUNT"
if [ "$INITIAL_COUNT" == "$FINAL_COUNT" ]; then
    echo "✓ La suppression a réussi (retour au nombre initial)"
else
    echo "⚠ Attention: Le nombre d'employés a changé"
fi
echo ""

echo -e "${GREEN}=== Tests terminés avec succès! ===${NC}"
echo ""
echo "Pour tester manuellement:"
echo "  GET tous les employés:  curl http://localhost:5000/employees | jq"
echo "  GET un employé:         curl http://localhost:5000/employees/1 | jq"
echo "  POST créer:             curl -X POST http://localhost:5000/employees -H 'Content-Type: application/json' -d '{\"name\":\"...\",\"address\":\"...\",\"salary\":50000}' | jq"
echo "  PUT mettre à jour:      curl -X PUT http://localhost:5000/employees/1 -H 'Content-Type: application/json' -d '{\"salary\":60000}' | jq"
echo "  DELETE supprimer:       curl -X DELETE http://localhost:5000/employees/1 | jq"
echo "  GET statistiques:       curl http://localhost:5000/stats | jq"
