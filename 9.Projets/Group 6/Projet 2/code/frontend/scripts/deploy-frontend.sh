#!/bin/bash
# ============================================================
# deploy-frontend.sh
# Déploiement du frontend React sur Tomcat (EC2)
# Usage : ./deploy-frontend.sh [IP_EC2]
# ============================================================

set -e

EC2_IP="${1:-13.49.229.69}"
TOMCAT_WEBAPPS="/opt/tomcat/webapps"
APP_NAME="frontend"
DEPLOY_DIR="${TOMCAT_WEBAPPS}/${APP_NAME}"

echo "╔══════════════════════════════════════╗"
echo "║   StockMaster — Deploy Frontend       ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "▶ IP EC2          : ${EC2_IP}"
echo "▶ Dossier Tomcat  : ${DEPLOY_DIR}"
echo ""

# ── 1. Mise à jour du .env.production ──────────────────────
echo "1/4  Mise à jour VITE_API_URL..."
echo "VITE_API_URL=http://${EC2_IP}:8080/stockmaster/api" > .env.production
echo "     → VITE_API_URL=http://${EC2_IP}:8080/stockmaster/api"

# ── 2. Installation des dépendances ────────────────────────
echo ""
echo "2/4  Installation des dépendances npm..."
npm ci --silent

# ── 3. Build de production ─────────────────────────────────
echo ""
echo "3/4  Build React (Vite)..."
npm run build
echo "     → dist/ généré avec succès"

# ── 4. Déploiement sur Tomcat ──────────────────────────────
echo ""
echo "4/4  Déploiement sur Tomcat..."

# Créer le dossier webapp si nécessaire
sudo mkdir -p "${DEPLOY_DIR}"

# Vider l'ancien déploiement
sudo rm -rf "${DEPLOY_DIR:?}"/*

# Copier le build
sudo cp -r dist/* "${DEPLOY_DIR}/"

# Créer le WEB-INF/web.xml pour le routing SPA
sudo mkdir -p "${DEPLOY_DIR}/WEB-INF"
sudo tee "${DEPLOY_DIR}/WEB-INF/web.xml" > /dev/null <<'WEBXML'
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee https://jakarta.ee/xml/ns/jakartaee/web-app_5_0.xsd"
         version="5.0">
  <display-name>StockMaster Frontend</display-name>
  <error-page>
    <error-code>404</error-code>
    <location>/index.html</location>
  </error-page>
</web-app>
WEBXML

echo "     → Fichiers copiés dans ${DEPLOY_DIR}"
echo ""
echo "✅  Déploiement terminé !"
echo ""
echo "🌐  URL d'accès : http://${EC2_IP}:8080/${APP_NAME}/"
echo "     (HashRouter : toutes les routes passent par index.html)"
echo ""
