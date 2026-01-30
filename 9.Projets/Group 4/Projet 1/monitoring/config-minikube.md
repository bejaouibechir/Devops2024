# Quick Start Minikube

## 1. Installation
```bash
# Installer socat
sudo apt-get install -y socat  # Ubuntu/Debian
# ou: sudo yum install -y socat  # RHEL/CentOS
# ou: brew install socat         # macOS

# Déployer monitoring
chmod +x install-monitoring.sh
./install-monitoring.sh
```

## 2. Accès Grafana
```bash
# Option A: Auto-open
minikube service grafana -n monitoring

# Option B: Port-forward
kubectl port-forward -n monitoring svc/grafana 3000:3000
# http://localhost:3000
# User: admin / Pass: admin
```

## 3. Importer Dashboards
```
Grafana → + → Import → Enter ID:
- 7362  (MySQL Overview) ⭐
- 6239  (InnoDB Metrics)
- 14057 (Quick Start)
```

## 4. Vérifications
```bash
# MySQL UP?
kubectl port-forward -n mysql-app svc/mysql-exporter 9104:9104 &
curl localhost:9104/metrics | grep mysql_up

# Prometheus targets
minikube service prometheus -n monitoring
# Status → Targets → mysql-exporter (UP)
```

## Firewall
**Ajouter exceptions:**
- 30090 (Prometheus)
- 30300 (Grafana)
- 30306 (MySQL)

## Troubleshooting
```bash
# Services
minikube service list

# Logs
kubectl logs -n mysql-app -l app=mysql-exporter
kubectl logs -n monitoring -l app=prometheus

# Restart
minikube stop && minikube start
```
