#!/bin/bash
set -e

echo "🚀 Installation Monitoring MySQL Minimal (Minikube)"
echo "===================================================="
echo ""

# Vérifier Minikube
if ! command -v minikube &> /dev/null; then
    echo "❌ Minikube non installé"
    exit 1
fi

# Vérifier socat
if ! command -v socat &> /dev/null; then
    echo "⚠️  socat non installé - Installation..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y socat || sudo yum install -y socat
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install socat
    fi
fi

echo "✅ Prérequis OK"
echo ""

# Déployer Prometheus + Grafana
echo "📈 Déploiement Prometheus + Grafana..."
kubectl apply -f prometheus-grafana.yaml
echo "✅ Déployé"
echo ""

# Configurer Prometheus pour cAdvisor
echo "⚙️  Configuration Prometheus (cAdvisor)..."

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
      
      - job_name: 'kubernetes-nodes-cadvisor'
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        kubernetes_sd_configs:
          - role: node
        relabel_configs:
          - action: labelmap
            regex: __meta_kubernetes_node_label_(.+)
          - target_label: __address__
            replacement: kubernetes.default.svc:443
          - source_labels: [__meta_kubernetes_node_name]
            regex: (.+)
            target_label: __metrics_path__
            replacement: /api/v1/nodes/\${1}/proxy/metrics/cadvisor
EOF

# Créer RBAC pour Prometheus
echo "🔐 Configuration RBAC..."

kubectl create serviceaccount prometheus -n monitoring --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources:
  - configmaps
  verbs: ["get"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring
EOF

# Patcher Prometheus pour utiliser ServiceAccount
kubectl patch deployment prometheus -n monitoring -p '{"spec":{"template":{"spec":{"serviceAccountName":"prometheus"}}}}'

echo "✅ Configuration terminée"
echo ""

# Attente pods
echo "⏳ Attente démarrage pods..."
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=120s 2>/dev/null || echo "⚠️  Prometheus timeout (normal si premier démarrage)"
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=120s 2>/dev/null || echo "⚠️  Grafana timeout (normal si premier démarrage)"
echo ""

# Status
echo "📋 Status:"
kubectl get pods -n monitoring
echo ""

# Infos accès
echo "🌐 ACCÈS GRAFANA:"
echo ""
echo "MÉTHODE 1 - Minikube Service (RECOMMANDÉ):"
echo "  minikube service grafana -n monitoring --url"
echo "  Utiliser l'URL retournée dans le navigateur"
echo ""
echo "MÉTHODE 2 - Port-Forward:"
echo "  pkill -f 'port-forward'"
echo "  kubectl port-forward -n monitoring svc/grafana 3000:3000 --address='0.0.0.0' &"
echo "  http://VOTRE_IP:3000"
echo ""
echo "Login: admin / admin"
echo ""

echo "🎯 PROCHAINES ÉTAPES:"
echo "1. Ouvrir Grafana"
echo "2. Créer dashboard avec les queries:"
echo "   - Mémoire: container_memory_working_set_bytes{pod=\"mysql-0\",namespace=\"mysql-app\"}"
echo "   - CPU: rate(container_cpu_usage_seconds_total{pod=\"mysql-0\",namespace=\"mysql-app\"}[5m])"
echo ""
echo "📖 Voir README-MONITORING-MINIMAL.md pour les détails"
echo ""

echo "⚠️  FIREWALL: Ajouter exception port 3000"
echo ""
echo "✅ Installation terminée!"
