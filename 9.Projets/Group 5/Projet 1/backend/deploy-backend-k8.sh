#!/bin/bash
set -e

echo "☸️  PARTIE II - Déploiement Kubernetes"
echo "======================================"
echo ""

# Variables
DOCKER_USERNAME="${DOCKER_USERNAME:-votre-username}"
IMAGE_NAME="mysql-flask-backend"
IMAGE_TAG="1.0"

# ═══════════════════════════════════════════════════════════
echo "CONFIGURATION"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "📝 Docker Hub username: ${DOCKER_USERNAME}"
read -p "Entrer votre Docker Hub username (ou Enter pour garder): " INPUT_USERNAME
if [ -n "$INPUT_USERNAME" ]; then
    DOCKER_USERNAME=$INPUT_USERNAME
fi

FULL_IMAGE="${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "🐳 Image à déployer: ${FULL_IMAGE}"
echo ""

# ═══════════════════════════════════════════════════════════
echo "ÉTAPE 1 - VÉRIFICATIONS"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Vérifier Kubernetes
echo "☸️  Vérification cluster Kubernetes..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Pas de connexion au cluster Kubernetes"
    exit 1
fi
echo "✅ Cluster Kubernetes accessible"
echo ""

# Vérifier MySQL
echo "🔍 Vérification MySQL..."
if ! kubectl get statefulset mysql -n mysql-app &> /dev/null; then
    echo "❌ MySQL n'est pas déployé"
    echo "Déployez d'abord MySQL avec: ./deploy-mysql.sh"
    exit 1
fi

if ! kubectl get pod mysql-0 -n mysql-app -o jsonpath='{.status.phase}' | grep -q "Running"; then
    echo "❌ MySQL n'est pas en cours d'exécution"
    exit 1
fi
echo "✅ MySQL opérationnel"
echo ""

# Vérifier metrics-server
echo "📊 Vérification metrics-server..."
if ! kubectl get deployment metrics-server -n kube-system &> /dev/null; then
    echo "⚠️  metrics-server non trouvé - Activation..."
    minikube addons enable metrics-server
    sleep 10
fi
echo "✅ metrics-server activé"
echo ""

# ═══════════════════════════════════════════════════════════
echo "ÉTAPE 2 - MISE À JOUR MANIFESTS"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "📝 Mise à jour image dans deployment..."

# Créer fichier deployment avec bonne image
cat > k8s/02-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-backend
  namespace: mysql-app
  labels:
    app: flask-backend
    version: "1.0"
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask-backend
  template:
    metadata:
      labels:
        app: flask-backend
        version: "1.0"
    spec:
      containers:
      - name: flask-app
        image: ${FULL_IMAGE}
        imagePullPolicy: Always
        ports:
        - containerPort: 5000
          name: http
        env:
        - name: MYSQL_HOST
          value: "mysql-service.mysql-app.svc.cluster.local"
        - name: MYSQL_PORT
          value: "3306"
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: backend-secrets
              key: MYSQL_USER
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: backend-secrets
              key: MYSQL_PASSWORD
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: backend-secrets
              key: MYSQL_DATABASE
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 15
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
EOF

echo "✅ Deployment mis à jour avec: ${FULL_IMAGE}"
echo ""

# ═══════════════════════════════════════════════════════════
echo "ÉTAPE 3 - DÉPLOIEMENT"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "📦 Déploiement des ressources Kubernetes..."
echo ""

echo "  → Secret..."
kubectl apply -f k8s/01-secret.yaml

echo "  → Deployment..."
kubectl apply -f k8s/02-deployment.yaml

echo "  → Service..."
kubectl apply -f k8s/03-service.yaml

echo "  → HPA..."
kubectl apply -f k8s/04-hpa.yaml

echo ""
echo "✅ Ressources déployées"
echo ""

# ═══════════════════════════════════════════════════════════
echo "ÉTAPE 4 - ATTENTE PODS"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "⏳ Attente démarrage pods backend..."
kubectl wait --for=condition=ready pod -l app=flask-backend -n mysql-app --timeout=180s 2>/dev/null || echo "⚠️  Timeout (vérifier logs)"
echo ""

# ═══════════════════════════════════════════════════════════
echo "ÉTAPE 5 - VÉRIFICATIONS"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "📋 Status des ressources:"
echo ""
echo "Pods:"
kubectl get pods -n mysql-app -l app=flask-backend
echo ""
echo "Services:"
kubectl get svc -n mysql-app | grep flask
echo ""
echo "HPA:"
kubectl get hpa -n mysql-app
echo ""

# ═══════════════════════════════════════════════════════════
echo "ÉTAPE 6 - TEST API"
echo "═══════════════════════════════════════════════════════════"
echo ""

sleep 5

POD=$(kubectl get pod -n mysql-app -l app=flask-backend -o jsonpath='{.items[0].metadata.name}')
if [ -n "$POD" ]; then
    echo "🧪 Test health endpoint:"
    kubectl exec -n mysql-app $POD -- curl -s http://localhost:5000/health || echo "⚠️  Health check failed"
    echo ""
    
    echo "🧪 Test employees endpoint:"
    kubectl exec -n mysql-app $POD -- curl -s http://localhost:5000/employees | head -50 || echo "⚠️  Employees endpoint failed"
    echo ""
fi

# ═══════════════════════════════════════════════════════════
echo "ACCÈS API"
echo "═══════════════════════════════════════════════════════════"
echo ""

INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || hostname -I | awk '{print $1}')

echo "🌐 NodePort (accès externe):"
echo "   http://${INSTANCE_IP}:30500"
echo ""
echo "⚠️  AJOUTER EXCEPTION FIREWALL PORT 30500"
echo ""
echo "🔧 Port-forward (développement):"
echo "   kubectl port-forward -n mysql-app svc/flask-backend 5000:5000 --address='0.0.0.0' &"
echo "   http://${INSTANCE_IP}:5000"
echo ""
echo "📚 Endpoints API:"
echo "   GET    /                    - Info API"
echo "   GET    /health              - Health check"
echo "   GET    /employees           - Liste employés"
echo "   POST   /employees           - Créer employé"
echo "   GET    /employees/<id>      - Employé spécifique"
echo "   PUT    /employees/<id>      - Modifier employé"
echo "   DELETE /employees/<id>      - Supprimer employé"
echo "   GET    /stats               - Statistiques"
echo ""

# ═══════════════════════════════════════════════════════════
echo "EXEMPLES CURL"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "# Health check"
echo "curl http://${INSTANCE_IP}:30500/health"
echo ""
echo "# Liste employés"
echo "curl http://${INSTANCE_IP}:30500/employees"
echo ""
echo "# Créer employé"
echo "curl -X POST http://${INSTANCE_IP}:30500/employees \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"name\":\"Test User\",\"address\":\"Test Address\",\"salary\":50000,\"department\":\"IT\"}'"
echo ""
echo "# Statistiques"
echo "curl http://${INSTANCE_IP}:30500/stats"
echo ""

echo "✅ Déploiement Kubernetes terminé!"
echo ""
