#!/bin/bash
set -e

echo "🐳 PARTIE I - Build, Test & Push Docker Image"
echo "=============================================="
echo ""

# Variables
IMAGE_NAME="mysql-flask-backend"
IMAGE_TAG="1.0"
DOCKER_USERNAME="${DOCKER_USERNAME:-votre-username}"  # À remplacer
TEST_CONTAINER_NAME="test-flask-backend"

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "src/Dockerfile" ]; then
    echo "❌ Erreur: Fichier src/Dockerfile introuvable"
    echo "Assurez-vous d'être dans le répertoire backend/"
    exit 1
fi

# ═══════════════════════════════════════════════════════════
echo "ÉTAPE 1 - BUILD IMAGE"
echo "═══════════════════════════════════════════════════════════"
echo ""

cd src
echo "🔨 Build de l'image Docker..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
echo "✅ Image construite: ${IMAGE_NAME}:${IMAGE_TAG}"
cd ..
echo ""

# ═══════════════════════════════════════════════════════════
echo "ÉTAPE 2 - TEST IMAGE AVEC CONTAINER"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Vérifier si MySQL tourne
echo "🔍 Vérification MySQL..."
if ! kubectl get pod mysql-0 -n mysql-app &> /dev/null; then
    echo "⚠️  MySQL n'est pas déployé sur Kubernetes"
    echo "Le test utilisera des variables d'environnement mock"
    MYSQL_HOST="localhost"
else
    # Obtenir l'IP du service MySQL
    MYSQL_HOST=$(kubectl get svc mysql-service -n mysql-app -o jsonpath='{.spec.clusterIP}')
    echo "✅ MySQL trouvé: ${MYSQL_HOST}"
fi

echo ""
echo "🧪 Démarrage container de test..."

# Nettoyer ancien container si existe
docker rm -f ${TEST_CONTAINER_NAME} 2>/dev/null || true

# Démarrer container
docker run -d \
  --name ${TEST_CONTAINER_NAME} \
  -p 5000:5000 \
  -e MYSQL_HOST="${MYSQL_HOST}" \
  -e MYSQL_PORT=3306 \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=AppU5er@2024 \
  -e MYSQL_DATABASE=businessdb \
  ${IMAGE_NAME}:${IMAGE_TAG}

echo "✅ Container démarré"
echo ""

# Attendre que l'app démarre
echo "⏳ Attente démarrage application..."
sleep 5

# Test health endpoint
echo "🧪 Test endpoint /health..."
if curl -f http://localhost:5000/health 2>/dev/null; then
    echo "✅ Health check OK"
else
    echo "⚠️  Health check failed (normal si MySQL non accessible)"
fi
echo ""

# Test endpoint racine
echo "🧪 Test endpoint /..."
curl -s http://localhost:5000/ | head -20
echo ""
echo ""

# Voir logs
echo "📋 Logs du container:"
docker logs ${TEST_CONTAINER_NAME} | tail -20
echo ""

# ═══════════════════════════════════════════════════════════
echo "ÉTAPE 3 - NETTOYAGE TEST"
echo "═══════════════════════════════════════════════════════════"
echo ""

read -p "Le test est OK ? Continuer avec push vers Docker Hub ? (o/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    echo "❌ Arrêt du script"
    docker stop ${TEST_CONTAINER_NAME}
    docker rm ${TEST_CONTAINER_NAME}
    exit 1
fi

echo "🧹 Nettoyage container de test..."
docker stop ${TEST_CONTAINER_NAME}
docker rm ${TEST_CONTAINER_NAME}
echo "✅ Container supprimé"
echo ""

# ═══════════════════════════════════════════════════════════
echo "ÉTAPE 4 - TAG IMAGE"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "📝 Docker Hub username actuel: ${DOCKER_USERNAME}"
read -p "Entrer votre Docker Hub username (ou Enter pour garder): " INPUT_USERNAME
if [ -n "$INPUT_USERNAME" ]; then
    DOCKER_USERNAME=$INPUT_USERNAME
fi

echo ""
echo "🏷️  Tag de l'image..."
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_USERNAME}/${IMAGE_NAME}:latest
echo "✅ Images taguées:"
echo "   ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
echo "   ${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
echo ""

# ═══════════════════════════════════════════════════════════
echo "ÉTAPE 5 - DOCKER LOGIN"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "🔐 Connexion à Docker Hub..."
docker login
echo "✅ Connecté à Docker Hub"
echo ""

# ═══════════════════════════════════════════════════════════
echo "ÉTAPE 6 - PUSH VERS DOCKER HUB"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "📤 Push de l'image vers Docker Hub..."
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:latest
echo "✅ Images poussées vers Docker Hub"
echo ""

# ═══════════════════════════════════════════════════════════
echo "RÉSUMÉ"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "✅ Image construite: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "✅ Tests effectués"
echo "✅ Image poussée vers: ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "🔗 Lien Docker Hub:"
echo "   https://hub.docker.com/r/${DOCKER_USERNAME}/${IMAGE_NAME}"
echo ""
echo "📝 Pour Kubernetes, utiliser:"
echo "   image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "➡️  PROCHAINE ÉTAPE: Partie II - Déploiement Kubernetes"
echo "   ./deploy-backend-k8s.sh"
echo ""
