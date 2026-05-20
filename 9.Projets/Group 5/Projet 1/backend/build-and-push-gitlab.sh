#!/bin/bash
set -e

echo "🐳 PARTIE I - Build, Test & Push Docker Image (vers GitLab Registry)"
echo "========================================================"
echo ""

# Variables
IMAGE_NAME="mysql-flask-backend"
IMAGE_TAG="1.0"
TEST_CONTAINER_NAME="test-flask-backend"

# Charger les variables depuis .env
if [ -f ".env" ]; then
    source .env
    echo "✅ .env chargé"
else
    echo "❌ Fichier .env introuvable !"
    echo "Créez-le avec les variables suivantes :"
    echo "  GITLAB_REGISTRY=registry.gitlab.com"
    echo "  GITLAB_GROUP_OR_USER=votre-compte-ou-groupe"
    echo "  GITLAB_PROJECT=projet"
    echo "  GITLAB_REGISTRY_TOKEN=votre-token-personnel-ou-deploy-token"
    exit 1
fi

# Construire le nom complet de l'image
REGISTRY_IMAGE="${GITLAB_REGISTRY}/${GITLAB_GROUP_OR_USER}/${GITLAB_PROJECT}/${IMAGE_NAME}"

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
docker build -t ${REGISTRY_IMAGE}:${IMAGE_TAG} .
echo "✅ Image construite: ${REGISTRY_IMAGE}:${IMAGE_TAG}"
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
  ${REGISTRY_IMAGE}:${IMAGE_TAG}

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

read -p "Le test est OK ? Continuer avec push vers GitLab Registry ? (o/n): " -n 1 -r
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
echo "ÉTAPE 4 - TAG supplémentaire (latest)"
echo "═══════════════════════════════════════════════════════════"
echo ""

docker tag ${REGISTRY_IMAGE}:${IMAGE_TAG} ${REGISTRY_IMAGE}:latest
echo "✅ Tag :latest ajouté"
echo ""

# ═══════════════════════════════════════════════════════════
echo "ÉTAPE 5 - LOGIN GITLAB REGISTRY"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "🔐 Connexion à GitLab Container Registry..."
echo "${GITLAB_REGISTRY_TOKEN}" | docker login ${GITLAB_REGISTRY} \
    --username "${GITLAB_GROUP_OR_USER}" \
    --password-stdin
echo "✅ Connecté à ${GITLAB_REGISTRY}"
echo ""

# ═══════════════════════════════════════════════════════════
echo "ÉTAPE 6 - PUSH VERS GITLAB REGISTRY"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "📤 Push de l'image vers GitLab..."
docker push ${REGISTRY_IMAGE}:${IMAGE_TAG}
docker push ${REGISTRY_IMAGE}:latest
echo "✅ Images poussées vers GitLab Registry"
echo ""

# ═══════════════════════════════════════════════════════════
echo "RÉSUMÉ"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "✅ Image construite: ${REGISTRY_IMAGE}:${IMAGE_TAG}"
echo "✅ Tests effectués"
echo "✅ Image poussée vers:"
echo "   ${REGISTRY_IMAGE}:${IMAGE_TAG}"
echo "   ${REGISTRY_IMAGE}:latest"
echo ""
echo "🔗 Lien GitLab Container Registry:"
echo "   https://${GITLAB_REGISTRY}/${GITLAB_GROUP_OR_USER}/${GITLAB_PROJECT}/container_registry"
echo ""
echo "📝 Pour Kubernetes, utiliser:"
echo "   image: ${REGISTRY_IMAGE}:${IMAGE_TAG}"
echo ""
echo "➡️  PROCHAINE ÉTAPE: Partie II - Déploiement Kubernetes"
echo "   ./deploy-backend-k8s.sh"
echo ""