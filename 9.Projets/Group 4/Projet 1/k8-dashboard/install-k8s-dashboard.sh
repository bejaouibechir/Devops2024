#!/bin/bash
set -e

echo "🚀 Installation Kubernetes Dashboard (Minikube)"
echo "==============================================="
echo ""

# 1. Activer addon dashboard
echo "📊 Activation addon dashboard..."
minikube addons enable dashboard
minikube addons enable metrics-server
echo "✅ Addons activés"
echo ""

# 2. Attendre que les pods soient prêts
echo "⏳ Attente démarrage dashboard..."
kubectl wait --for=condition=ready pod -l k8s-app=kubernetes-dashboard -n kubernetes-dashboard --timeout=120s 2>/dev/null || echo "⚠️  Timeout (continuer...)"
echo ""

# 3. Status
echo "📋 Status:"
kubectl get pods -n kubernetes-dashboard
echo ""

# 4. Lancer kubectl proxy
echo "🌐 Lancement kubectl proxy..."
pkill -f "kubectl proxy" 2>/dev/null || true
kubectl proxy --address='0.0.0.0' --accept-hosts='.*' --port=8001 &
sleep 3
echo "✅ Proxy démarré sur port 8001"
echo ""

# 5. Instructions accès
echo "═══════════════════════════════════════════════════════"
echo "🌐 ACCÈS DASHBOARD"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "⚠️  AJOUTER EXCEPTION FIREWALL/SECURITY GROUP: Port 8001"
echo ""
echo "URL du Dashboard:"
echo "  http://VOTRE_IP:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/"
echo ""
echo "Exemple:"
INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || hostname -I | awk '{print $1}')
echo "  http://${INSTANCE_IP}:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/"
echo ""
echo "✅ Pas de login requis - Accès direct via proxy"
echo ""
echo "📝 Le proxy doit rester actif en background"
echo ""
echo "✅ Installation terminée!"
