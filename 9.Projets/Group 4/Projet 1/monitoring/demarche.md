# Monitoring MySQL - Prometheus + Grafana - Démarche Manuelle (Minikube)

## Objectif

Mettre en place un monitoring minimal de MySQL avec Prometheus et Grafana, en utilisant cAdvisor (métriques conteneurs natives Kubernetes).

## Prérequis

- Minikube installé et démarré
- MySQL déjà déployé dans namespace `mysql-app`
- kubectl configuré
- socat installé

## Architecture de monitoring

```
Grafana (UI) → Prometheus (DB) → cAdvisor (Collecteur) → MySQL Pod
```

## Vérifications préalables

### 1. Vérifier Minikube

```bash
minikube status
```

### 2. Vérifier MySQL déployé

```bash
kubectl get pods -n mysql-app -l app=mysql
```

**Résultat attendu:**

```
NAME      READY   STATUS    RESTARTS   AGE
mysql-0   1/1     Running   0          30m
```

### 3. Vérifier/Installer socat

```bash
# Vérifier
command -v socat

# Si absent, installer
sudo apt-get update && sudo apt-get install -y socat
```

---

## Étape 1 - Déployer Prometheus + Grafana

### Commande

```bash
kubectl apply -f prometheus-grafana.yaml
```

**Résultat attendu:**

```
namespace/monitoring created
configmap/prometheus-config created
deployment.apps/prometheus created
service/prometheus created
configmap/grafana-datasources created
deployment.apps/grafana created
service/grafana created
```

### Vérification

```bash
kubectl get all -n monitoring
```

**Résultat attendu:**

```
NAME                              READY   STATUS    RESTARTS   AGE
pod/prometheus-xxxxxxxxxx-xxxxx   1/1     Running   0          30s
pod/grafana-xxxxxxxxxx-xxxxx      1/1     Running   0          30s

NAME                 TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/prometheus   NodePort   10.96.xxx.xxx   <none>        9090:30090/TCP   30s
service/grafana      NodePort   10.96.xxx.xxx   <none>        3000:30300/TCP   30s

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prometheus   1/1     1            1           30s
deployment.apps/grafana      1/1     1            1           30s
```

---

## Étape 2 - Configurer Prometheus pour cAdvisor

### Créer ServiceAccount Prometheus

```bash
kubectl create serviceaccount prometheus -n monitoring
```

**Résultat attendu:**

```
serviceaccount/prometheus created
```

### Créer ClusterRole

```bash
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
```

**Résultat attendu:**

```
clusterrole.rbac.authorization.k8s.io/prometheus created
```

### Créer ClusterRoleBinding

```bash
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
```

**Résultat attendu:**

```
clusterrolebinding.rbac.authorization.k8s.io/prometheus created
```

---

## Étape 3 - Mettre à jour ConfigMap Prometheus

### Appliquer nouvelle configuration

```bash
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
```

**Résultat attendu:**

```
configmap/prometheus-config configured
```

---

## Étape 4 - Patcher Prometheus pour utiliser ServiceAccount

### Commande

```bash
kubectl patch deployment prometheus -n monitoring -p '{"spec":{"template":{"spec":{"serviceAccountName":"prometheus"}}}}'
```

**Résultat attendu:**

```
deployment.apps/prometheus patched
```

### Attendre redémarrage

```bash
kubectl rollout status deployment/prometheus -n monitoring
```

**Résultat attendu:**

```
deployment "prometheus" successfully rolled out
```

---

## Étape 5 - Attendre que les pods soient prêts

### Prometheus

```bash
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=120s
```

**Résultat attendu:**

```
pod/prometheus-xxxxxxxxxx-xxxxx condition met
```

### Grafana

```bash
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=120s
```

**Résultat attendu:**

```
pod/grafana-xxxxxxxxxx-xxxxx condition met
```

### Vérifier tous les pods

```bash
kubectl get pods -n monitoring
```

**Résultat attendu:**

```
NAME                          READY   STATUS    RESTARTS   AGE
prometheus-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
grafana-xxxxxxxxxx-xxxxx      1/1     Running   0          5m
```

---

## Étape 6 - Accéder à Grafana

### Méthode 1: minikube service (RECOMMANDÉ)

```bash
minikube service grafana -n monitoring --url
```

**Résultat:**

```
http://192.168.49.2:30300
```

Ouvrir cette URL dans le navigateur.

### Méthode 2: Port-forward

```bash
# Arrêter anciens port-forwards
pkill -f "port-forward"

# Lancer port-forward
kubectl port-forward -n monitoring svc/grafana 3000:3000 --address='0.0.0.0' &
```

**Ajouter exception firewall port 3000**

Accéder: `http://VOTRE_IP:3000`

### Login Grafana

- **User:** `admin`
- **Password:** `admin`

(Grafana demandera de changer le mot de passe - vous pouvez skip)

---

## Étape 7 - Vérifier Prometheus

### Accéder à Prometheus

```bash
minikube service prometheus -n monitoring --url
```

Ou:

```bash
kubectl port-forward -n monitoring svc/prometheus 9090:9090 --address='0.0.0.0' &
```

### Vérifier les targets

Dans Prometheus UI:

1. Aller dans **Status** → **Targets**
2. Vérifier que `kubernetes-nodes-cadvisor` est **UP**

### Tester une query

Dans Prometheus → **Graph**:

```promql
container_memory_working_set_bytes{namespace="mysql-app",pod="mysql-0"}
```

**Résultat attendu:** Des données s'affichent

---

## Étape 8 - Créer Dashboard Grafana

### Panel 1 - Mémoire MySQL

1. Dans Grafana, cliquer **+** → **Dashboard** → **Add visualization**
2. Sélectionner datasource **Prometheus**
3. Dans **Metric**, entrer:

```promql
container_memory_working_set_bytes{pod="mysql-0",namespace="mysql-app"}
```

4. Cliquer **Run queries**
5. Dans **Panel options** (à droite):
   - **Title:** `MySQL Memory Usage`
6. Dans **Standard options**:
   - **Unit:** `Data` → `bytes(IEC)`
7. Cliquer **Apply**

### Panel 2 - CPU MySQL

1. Cliquer **Add** → **Visualization**
2. Sélectionner datasource **Prometheus**
3. Dans **Metric**, entrer:

```promql
rate(container_cpu_usage_seconds_total{pod="mysql-0",namespace="mysql-app"}[5m])
```

4. Cliquer **Run queries**
5. Dans **Panel options**:
   - **Title:** `MySQL CPU Usage`
6. Dans **Standard options**:
   - **Unit:** `Misc` → `Percent (0.0-1.0)`
7. Cliquer **Apply**

### Sauvegarder le dashboard

1. Cliquer sur l'icône **💾 Save** (en haut à droite)
2. **Dashboard name:** `MySQL Monitoring`
3. Cliquer **Save**

---

## Étape 9 - Vérifier les métriques

### Dans le dashboard Grafana

Vous devriez voir:

- **Graphique mémoire:** ~380-400 MB (utilisation MySQL)
- **Graphique CPU:** ~0.01-0.05 (1-5% utilisation)

### Si "No data"

**Attendre 1-2 minutes** que Prometheus collecte les métriques

**Vérifier dans Prometheus:**

```bash
# Ouvrir Prometheus UI
minikube service prometheus -n monitoring --url

# Tester query
container_memory_working_set_bytes{namespace="mysql-app"}
```

---

## Métriques supplémentaires disponibles

### Réseau

```promql
# Réception
rate(container_network_receive_bytes_total{pod="mysql-0"}[5m])

# Transmission
rate(container_network_transmit_bytes_total{pod="mysql-0"}[5m])
```

### Filesystem

```promql
# Utilisation
container_fs_usage_bytes{pod="mysql-0"}

# Limite
container_fs_limit_bytes{pod="mysql-0"}
```

### Processus

```promql
container_processes{pod="mysql-0"}
```

---

## Commandes utiles

### Status des ressources monitoring

```bash
# Pods
kubectl get pods -n monitoring

# Services
kubectl get svc -n monitoring

# ConfigMaps
kubectl get cm -n monitoring

# ServiceAccount et RBAC
kubectl get sa -n monitoring
kubectl get clusterrole prometheus
kubectl get clusterrolebinding prometheus
```

### Logs

```bash
# Logs Prometheus
kubectl logs -n monitoring -l app=prometheus

# Logs Grafana
kubectl logs -n monitoring -l app=grafana
```

### Redémarrer

```bash
# Redémarrer Prometheus
kubectl rollout restart deployment/prometheus -n monitoring

# Redémarrer Grafana
kubectl rollout restart deployment/grafana -n monitoring
```

---

## Troubleshooting

### Grafana inaccessible

**1. Vérifier pod Grafana**

```bash
kubectl get pods -n monitoring -l app=grafana
```

**2. Voir logs**

```bash
kubectl logs -n monitoring -l app=grafana
```

**3. Redémarrer**

```bash
kubectl rollout restart deployment/grafana -n monitoring
```

**4. Port-forward**

```bash
pkill -f "port-forward.*3000"
kubectl port-forward -n monitoring svc/grafana 3000:3000 --address='0.0.0.0' &
```

### Dashboard affiche "No data"

**1. Vérifier Prometheus collecte les métriques**

```bash
# Ouvrir Prometheus
minikube service prometheus -n monitoring --url

# Dans Prometheus UI → Graph
container_memory_working_set_bytes{namespace="mysql-app"}
```

**2. Vérifier datasource Grafana**

Dans Grafana:

- Menu (☰) → **Connections** → **Data sources**
- Cliquer sur **Prometheus**
- **URL:** doit être `http://prometheus.monitoring.svc.cluster.local:9090`
- Cliquer **Save & test**

**Résultat:** "Successfully queried the Prometheus API."

**3. Attendre 1-2 minutes**

Prometheus collecte les métriques toutes les 15 secondes.

### Prometheus targets DOWN

**1. Vérifier ServiceAccount**

```bash
kubectl get sa prometheus -n monitoring
```

**2. Vérifier RBAC**

```bash
kubectl get clusterrole prometheus
kubectl get clusterrolebinding prometheus
```

**3. Vérifier que Prometheus utilise le ServiceAccount**

```bash
kubectl get deployment prometheus -n monitoring -o yaml | grep serviceAccountName
```

**Résultat attendu:**

```yaml
serviceAccountName: prometheus
```

**4. Redémarrer Prometheus**

```bash
kubectl rollout restart deployment/prometheus -n monitoring
```

---

## Désinstallation

### Supprimer namespace monitoring

```bash
kubectl delete namespace monitoring
```

### Supprimer RBAC Prometheus

```bash
kubectl delete clusterrolebinding prometheus
kubectl delete clusterrole prometheus
```

### Arrêter port-forwards

```bash
pkill -f "port-forward"
```

### Vérifier suppression

```bash
kubectl get all -n monitoring
```

**Résultat attendu:**

```
No resources found in monitoring namespace.
```

---

## Résumé des commandes

```bash
# 1. Déployer stack
kubectl apply -f prometheus-grafana.yaml

# 2. Créer ServiceAccount
kubectl create serviceaccount prometheus -n monitoring

# 3. Créer ClusterRole et Binding
kubectl apply -f <clusterrole.yaml>
kubectl apply -f <clusterrolebinding.yaml>

# 4. Mettre à jour ConfigMap Prometheus
kubectl apply -f <prometheus-config.yaml>

# 5. Patcher Prometheus
kubectl patch deployment prometheus -n monitoring -p '{"spec":{"template":{"spec":{"serviceAccountName":"prometheus"}}}}'

# 6. Attendre pods ready
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=120s
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=120s

# 7. Accéder Grafana
minikube service grafana -n monitoring --url
# Ou: kubectl port-forward -n monitoring svc/grafana 3000:3000 --address='0.0.0.0' &

# 8. Login: admin / admin

# 9. Créer dashboard avec queries:
# - container_memory_working_set_bytes{pod="mysql-0",namespace="mysql-app"}
# - rate(container_cpu_usage_seconds_total{pod="mysql-0",namespace="mysql-app"}[5m])
```

---

## Points clés à retenir

1. **Pas de MySQL Exporter** : Solution simplifiée avec cAdvisor (métriques natives Kubernetes)
2. **RBAC nécessaire** : ServiceAccount + ClusterRole + ClusterRoleBinding pour Prometheus
3. **cAdvisor** : Intégré dans kubelet, collecte métriques conteneurs automatiquement
4. **Métriques disponibles** : CPU, Mémoire, Network, Filesystem des conteneurs
5. **Grafana datasource** : Configurée automatiquement vers Prometheus
6. **Suffisant pour démonstration** : Monitoring basique mais fonctionnel

## Métriques PromQL essentielles

```promql
# Mémoire MySQL
container_memory_working_set_bytes{pod="mysql-0",namespace="mysql-app"}

# CPU MySQL  
rate(container_cpu_usage_seconds_total{pod="mysql-0",namespace="mysql-app"}[5m])

# Network RX
rate(container_network_receive_bytes_total{pod="mysql-0"}[5m])

# Network TX
rate(container_network_transmit_bytes_total{pod="mysql-0"}[5m])

# Filesystem
container_fs_usage_bytes{pod="mysql-0"}
```
