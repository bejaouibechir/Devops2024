#!/bin/bash
set -e

# ─── CONFIGURATION ────────────────────────────────────────────────
TOMCAT_WEBAPPS="/opt/tomcat/webapps"
WAR_NAME="stockmaster"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SPRING_PROFILE="prod"
# ──────────────────────────────────────────────────────────────────

echo "=== [1/4] Build du projet Maven ==="
cd "${PROJECT_DIR}"

if command -v mvn &>/dev/null; then
    MVN_CMD="mvn"
elif [ -f "./mvnw" ]; then
    MVN_CMD="./mvnw"
else
    echo "Maven non trouvé, installation..."
    sudo apt-get install -y maven -q
    MVN_CMD="mvn"
fi

${MVN_CMD} clean package -DskipTests -q
echo "✅ Build terminé"

WAR_FILE=$(find target -name "*.war" | head -1)
if [ -z "${WAR_FILE}" ]; then
    echo "❌ Fichier WAR introuvable dans target/"
    exit 1
fi
echo "   WAR : ${WAR_FILE}"

echo "=== [2/4] Arrêt de Tomcat ==="
sudo systemctl stop tomcat || true
sleep 2

echo "=== [3/4] Déploiement du WAR ==="
sudo rm -rf "${TOMCAT_WEBAPPS}/${WAR_NAME}" "${TOMCAT_WEBAPPS}/${WAR_NAME}.war"
sudo cp "${WAR_FILE}" "${TOMCAT_WEBAPPS}/${WAR_NAME}.war"
sudo chown tomcat:tomcat "${TOMCAT_WEBAPPS}/${WAR_NAME}.war"
echo "✅ WAR copié dans ${TOMCAT_WEBAPPS}"

echo "=== [4/4] Démarrage de Tomcat avec profil ${SPRING_PROFILE} ==="
sudo tee /opt/tomcat/bin/setenv.sh > /dev/null <<EOF
export SPRING_PROFILES_ACTIVE=${SPRING_PROFILE}
export DB_URL=jdbc:postgresql://localhost:5433/stockmaster
export DB_USERNAME=stockmaster
export DB_PASSWORD=stockmaster123
export REDIS_HOST=localhost
export REDIS_PORT=6379
EOF
sudo chmod +x /opt/tomcat/bin/setenv.sh
sudo chown tomcat:tomcat /opt/tomcat/bin/setenv.sh

sudo systemctl start tomcat

echo ""
echo "⏳ Attente du démarrage (20s)..."
sleep 20

echo ""
echo "=== Vérification ==="
if curl -sf http://localhost:8080/${WAR_NAME}/api/reports/summary > /dev/null 2>&1; then
    echo "✅ Application démarrée : http://localhost:8080/${WAR_NAME}"
else
    echo "⚠️  Application en cours de démarrage ou erreur"
    echo "   Vérifier les logs : sudo tail -f /opt/tomcat/logs/catalina.out"
fi

echo ""
echo "URLs utiles :"
echo "  API       : http://localhost:8080/${WAR_NAME}/api"
echo "  Swagger   : http://localhost:8080/${WAR_NAME}/swagger-ui/index.html"
echo "  Logs      : sudo tail -f /opt/tomcat/logs/catalina.out"
