#!/bin/bash
set -e

# ─── CONFIGURATION ────────────────────────────────────────────────
POSTGRES_VERSION="15"
REDIS_VERSION="7"
POSTGRES_DB="stockmaster"
POSTGRES_USER="stockmaster"
POSTGRES_PASSWORD="stockmaster123"
POSTGRES_PORT="5433"
REDIS_PORT="6379"
NETWORK_NAME="stockmaster-net"
# ──────────────────────────────────────────────────────────────────

echo "=== [1/5] Installation Docker ==="
if ! command -v docker &>/dev/null; then
    sudo apt-get update -q
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -q
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
    echo "✅ Docker installé"
else
    echo "✅ Docker déjà installé"
fi

docker --version

echo "=== [2/5] Création réseau Docker ==="
if ! docker network ls | grep -q "${NETWORK_NAME}"; then
    docker network create ${NETWORK_NAME}
    echo "✅ Réseau ${NETWORK_NAME} créé"
else
    echo "✅ Réseau ${NETWORK_NAME} existe déjà"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKER_DIR="${SCRIPT_DIR}/../docker"

echo "=== [3/5] Build et lancement PostgreSQL ==="
if docker ps -a | grep -q "stockmaster-postgres"; then
    echo "⚠️  Conteneur stockmaster-postgres existe, redémarrage..."
    docker start stockmaster-postgres
else
    docker build -t stockmaster-postgres:latest "${DOCKER_DIR}/postgres"
    docker run -d \
        --name stockmaster-postgres \
        --network ${NETWORK_NAME} \
        -p ${POSTGRES_PORT}:5432 \
        -v stockmaster-pgdata:/var/lib/postgresql/data \
        --restart unless-stopped \
        stockmaster-postgres:latest
    echo "✅ PostgreSQL démarré"
fi

echo "=== [4/5] Build et lancement Redis ==="
if docker ps -a | grep -q "stockmaster-redis"; then
    echo "⚠️  Conteneur stockmaster-redis existe, redémarrage..."
    docker start stockmaster-redis
else
    docker build -t stockmaster-redis:latest "${DOCKER_DIR}/redis"
    docker run -d \
        --name stockmaster-redis \
        --network ${NETWORK_NAME} \
        -p ${REDIS_PORT}:6379 \
        -v stockmaster-redisdata:/data \
        --restart unless-stopped \
        stockmaster-redis:latest
    echo "✅ Redis démarré"
fi

echo "=== [5/5] Vérification des services ==="
echo "Attente 5s pour initialisation..."
sleep 5

echo ""
echo "--- PostgreSQL ---"
docker exec stockmaster-postgres pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB} \
    && echo "✅ PostgreSQL: OK" || echo "❌ PostgreSQL: KO"

echo ""
echo "--- Redis ---"
docker exec stockmaster-redis redis-cli ping \
    && echo "✅ Redis: OK" || echo "❌ Redis: KO"

echo ""
echo "=== RÉSUMÉ ==="
docker ps --filter "name=stockmaster" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "Connexion PostgreSQL :"
echo "  Host     : localhost:${POSTGRES_PORT}"
echo "  Database : ${POSTGRES_DB}"
echo "  User     : ${POSTGRES_USER}"
echo "  Password : ${POSTGRES_PASSWORD}"
echo ""
echo "Connexion Redis :"
echo "  Host     : localhost:${REDIS_PORT}"
echo ""
echo "⚠️  Mettre à jour application-prod.yml avec ces credentials"
