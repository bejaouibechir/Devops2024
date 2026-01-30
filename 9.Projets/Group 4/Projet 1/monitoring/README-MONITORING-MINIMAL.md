# Monitoring MySQL - Solution Minimale (Minikube)

## Fichiers nécessaires
- `prometheus-grafana.yaml` ✅ (GARDER)
- `install-monitoring.sh` ✅ (GARDER - sera mis à jour)
- `monitor.sh` ✅ (GARDER)

**Fichiers inutiles à supprimer:**
- `mysql-exporter-fixed.yaml` ❌ (ne fonctionne pas)
- `mysql-exporter.yaml` ❌ (ne fonctionne pas)
- `prometheus-rules.yaml` ❌ (pas nécessaire)
- `config-minikube.md` ❌ (obsolète)

## Prérequis

```bash
# Installer socat
sudo apt-get install -y socat  # Ubuntu/Debian
```

## Installation

### 1. Déployer Prometheus + Grafana

```bash
chmod +x install-monitoring.sh
./install-monitoring.sh
```

### 2. Accéder à Grafana

```bash
# Méthode 1: minikube service (recommandé)
minikube service grafana -n monitoring --url

# Méthode 2: Port-forward
pkill -f "port-forward"
kubectl port-forward -n monitoring svc/grafana 3000:3000 --address='0.0.0.0' &
```

**Accès:** http://VOTRE_IP:3000
- User: `admin`
- Pass: `admin`

**⚠️ Ajouter exception firewall port 3000**

## Configuration Dashboard Grafana

### Étape 1: Créer nouveau dashboard

```
1. Dashboards → New Dashboard → Add visualization
2. Select "Prometheus" datasource
```

### Étape 2: Panel Mémoire MySQL

**Configuration:**
- Metric: `container_memory_working_set_bytes`
- Label filters:
  - `pod` = `mysql-0`
  - `namespace` = `mysql-app`
- Click "Run queries"

**Options du panel:**
- Title: `MySQL Memory Usage`
- Unit: Standard options → Unit → Data → `bytes(IEC)`
- Click "Apply"

### Étape 3: Panel CPU MySQL

```
1. Click "Add" → Visualization
2. Select "Prometheus"
```

**Configuration:**
- Metric: `rate(container_cpu_usage_seconds_total[5m])`
- Label filters:
  - `pod` = `mysql-0`
  - `namespace` = `mysql-app`
- Click "Run queries"

**Options du panel:**
- Title: `MySQL CPU Usage`
- Unit: Standard options → Unit → Misc → `Percent (0.0-1.0)`
- Click "Apply"

### Étape 4: Sauvegarder

```
Click "Save dashboard" (icône disquette en haut à droite)
Nom: MySQL Monitoring
Click "Save"
```

## Résultat attendu

Vous devriez voir:
- **Graphique mémoire**: ~380-400 MB (utilisation MySQL)
- **Graphique CPU**: ~0.01-0.05 (1-5% utilisation)

## Queries PromQL à copier-coller

### Mémoire MySQL
```promql
container_memory_working_set_bytes{pod="mysql-0",namespace="mysql-app"}
```

### CPU MySQL
```promql
rate(container_cpu_usage_seconds_total{pod="mysql-0",namespace="mysql-app"}[5m])
```

### Toutes les métriques disponibles
```promql
# Liste des métriques conteneurs
{namespace="mysql-app"}
```

## Vérification Prometheus

```bash
# Accéder à Prometheus
minikube service prometheus -n monitoring --url
# Ou: kubectl port-forward -n monitoring svc/prometheus 9090:9090 --address='0.0.0.0' &

# Dans Prometheus UI:
# Status → Targets → "kubernetes-nodes-cadvisor" doit être UP
# Graph → Entrer query: container_memory_working_set_bytes
```

## Monitoring CLI temps réel

```bash
chmod +x monitor.sh
./monitor.sh
```

Affiche en temps réel:
- Status des pods
- Services
- Events
- Resource usage

## Test MySQL

```bash
# Connexion MySQL
kubectl exec -it -n mysql-app mysql-0 -- mysql -uappuser -pAppU5er@2024 businessdb

# Requêtes
SELECT * FROM employees;
SELECT COUNT(*) FROM employees;
```

## Troubleshooting

### Grafana inaccessible

```bash
# Vérifier pod
kubectl get pods -n monitoring -l app=grafana

# Logs
kubectl logs -n monitoring -l app=grafana

# Redémarrer
kubectl rollout restart deployment/grafana -n monitoring

# Port-forward
pkill -f "port-forward"
kubectl port-forward -n monitoring svc/grafana 3000:3000 --address='0.0.0.0' &
```

### Pas de métriques dans Grafana

```bash
# Vérifier Prometheus
kubectl get pods -n monitoring -l app=prometheus

# Tester datasource
GRAFANA_POD=$(kubectl get pod -n monitoring -l app=grafana -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n monitoring $GRAFANA_POD -- wget -O- http://prometheus.monitoring.svc.cluster.local:9090/-/healthy

# Si erreur, reconfigurer datasource dans Grafana:
# Settings → Data Sources → Prometheus
# URL: http://prometheus.monitoring.svc.cluster.local:9090
# Save & Test
```

### Dashboard vide "No data"

```bash
# Vérifier que MySQL tourne
kubectl get pods -n mysql-app

# Vérifier métriques dans Prometheus
# Prometheus UI → Graph → Query: container_memory_working_set_bytes

# Attendre 1-2 minutes que les métriques se collectent
```

## Nettoyage

```bash
# Supprimer monitoring
kubectl delete namespace monitoring

# Supprimer MySQL (si nécessaire)
kubectl delete namespace mysql-app
```

## Architecture

```
┌─────────────────┐
│   Grafana       │  Port 3000 (UI)
│   (Dashboard)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Prometheus     │  Port 9090
│  (Metrics DB)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   cAdvisor      │  (Intégré kubelet)
│   (Collecteur)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   MySQL Pod     │  mysql-0
│   (Cible)       │
└─────────────────┘
```

## Notes

- **Pas de MySQL Exporter**: Solution simplifiée utilisant cAdvisor (métriques conteneurs natives)
- **Métriques disponibles**: CPU, Mémoire, Network, Disk I/O des conteneurs
- **Suffisant pour**: Démonstration pédagogique, monitoring basique
- **Production**: Utiliser MySQL Exporter + Alertmanager + dashboards avancés

## Métriques supplémentaires disponibles

```promql
# Réseau
rate(container_network_receive_bytes_total{pod="mysql-0"}[5m])
rate(container_network_transmit_bytes_total{pod="mysql-0"}[5m])

# Filesystem
container_fs_usage_bytes{pod="mysql-0"}
container_fs_limit_bytes{pod="mysql-0"}

# Processus
container_processes{pod="mysql-0"}
```

Vous pouvez ajouter ces métriques comme nouveaux panels dans le dashboard.
