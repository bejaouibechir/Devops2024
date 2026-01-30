# Déploiement MySQL sur Kubernetes

Ce projet contient tous les fichiers nécessaires pour déployer une instance MySQL sur Kubernetes avec StatefulSet, persistance des données et services.

## 📁 Structure des fichiers

```
.
├── 00-namespace.yaml          # Namespace mysql-app
├── 01-secret.yaml             # Secrets (mots de passe)
├── 02-configmap.yaml          # Script d'initialisation SQL
├── 03-statefulset.yaml        # StatefulSet MySQL (ORIGINAL - À REMPLACER)
├── 03-statefulset-fixed.yaml  # StatefulSet MySQL (CORRIGÉ - À UTILISER)
├── 04-services.yaml           # Services (Headless, ClusterIP, NodePort)
├── deploy-mysql.sh            # Script de déploiement automatique
├── ANALYSE_COHERENCE.md       # Analyse détaillée de la cohérence
└── README.md                  # Ce fichier
```

## 🔧 Prérequis

- Kubernetes cluster fonctionnel (minikube, kind, GKE, EKS, AKS, etc.)
- kubectl configuré et connecté au cluster
- StorageClass `standard` disponible (ou modifier dans le StatefulSet)

### Vérification des prérequis

```bash
# Vérifier kubectl
kubectl version --client

# Vérifier la connexion au cluster
kubectl cluster-info

# Vérifier les StorageClasses disponibles
kubectl get storageclass
```

## 🚀 Déploiement rapide (Méthode automatique)

### Option 1 : Script automatique (RECOMMANDÉ)

```bash
# 1. Remplacer le fichier StatefulSet original par la version corrigée
cp 03-statefulset-fixed.yaml 03-statefulset.yaml

# 2. Rendre le script exécutable
chmod +x deploy-mysql.sh

# 3. Déployer
./deploy-mysql.sh deploy

# Le script va :
# - Vérifier les prérequis
# - Déployer toutes les ressources dans le bon ordre
# - Attendre que MySQL soit prêt
# - Tester la connexion
# - Afficher les informations de connexion
```

### Option 2 : Déploiement manuel

```bash
# 1. Remplacer le fichier StatefulSet
cp 03-statefulset-fixed.yaml 03-statefulset.yaml

# 2. Créer le namespace
kubectl apply -f 00-namespace.yaml

# 3. Créer les secrets
kubectl apply -f 01-secret.yaml

# 4. Créer le ConfigMap
kubectl apply -f 02-configmap.yaml

# 5. Créer le StatefulSet
kubectl apply -f 03-statefulset.yaml

# 6. Créer les services
kubectl apply -f 04-services.yaml

# 7. Attendre que le pod soit prêt
kubectl wait --for=condition=ready pod -l app=mysql -n mysql-app --timeout=300s

# 8. Vérifier le statut
kubectl get all -n mysql-app
```

## 📊 Vérification du déploiement

### Vérifier le statut des ressources

```bash
# Toutes les ressources
kubectl get all -n mysql-app

# Pods
kubectl get pods -n mysql-app

# Services
kubectl get svc -n mysql-app

# PersistentVolumeClaims
kubectl get pvc -n mysql-app

# StatefulSet
kubectl get statefulset -n mysql-app
```

### Vérifier les logs

```bash
# Logs en temps réel
kubectl logs -f -n mysql-app mysql-0

# Logs des 100 dernières lignes
kubectl logs -n mysql-app mysql-0 --tail=100
```

## 🔐 Informations de connexion

### Credentials

| Paramètre | Valeur |
|-----------|--------|
| **Root Password** | `MySecureP@ssw0rd2024!` |
| **Database** | `businessdb` |
| **App User** | `appuser` |
| **App Password** | `AppU5er@2024` |

### Connexion depuis l'intérieur du cluster

```bash
# Hostname
mysql-service.mysql-app.svc.cluster.local

# Port
3306

# Commande de connexion
mysql -h mysql-service.mysql-app.svc.cluster.local -u appuser -p'AppU5er@2024' businessdb
```

### Connexion depuis l'extérieur (NodePort)

```bash
# Obtenir l'IP du node
kubectl get nodes -o wide

# Port NodePort
30306

# Exemple de connexion
mysql -h <NODE_IP> -P 30306 -u appuser -p'AppU5er@2024' businessdb
```

### Connexion locale avec port-forward

```bash
# Créer le port-forward
kubectl port-forward -n mysql-app svc/mysql-service 3306:3306

# Dans un autre terminal, se connecter
mysql -h 127.0.0.1 -P 3306 -u appuser -p'AppU5er@2024' businessdb
```

## 🧪 Tests de connexion

### Test direct depuis le pod

```bash
# Connexion root
kubectl exec -it -n mysql-app mysql-0 -- mysql -uroot -p'MySecureP@ssw0rd2024!'

# Une fois connecté, tester
SHOW DATABASES;
USE businessdb;
SHOW TABLES;
SELECT * FROM employees;
```

### Test avec l'utilisateur applicatif

```bash
kubectl exec -it -n mysql-app mysql-0 -- mysql -uappuser -p'AppU5er@2024' -D businessdb

# Tester les permissions
SELECT * FROM employees;
INSERT INTO employees (name, address, salary, department, hire_date) 
VALUES ('Test User', '123 Test Street', 50000.00, 'IT', '2024-01-01');
```

### Script de test automatique

```bash
# Utiliser le script fourni
./deploy-mysql.sh test
```

## 🔍 Commandes utiles

### Gestion du pod

```bash
# Se connecter au pod
kubectl exec -it -n mysql-app mysql-0 -- bash

# Redémarrer le StatefulSet
kubectl rollout restart statefulset/mysql -n mysql-app

# Supprimer et recréer le pod (les données persistent)
kubectl delete pod mysql-0 -n mysql-app
```

### Monitoring et debug

```bash
# Décrire le pod
kubectl describe pod mysql-0 -n mysql-app

# Événements du namespace
kubectl get events -n mysql-app --sort-by='.lastTimestamp'

# Vérifier l'utilisation des ressources
kubectl top pod -n mysql-app

# Inspecter le PVC
kubectl describe pvc mysql-data-mysql-0 -n mysql-app
```

### Backup et restore

```bash
# Faire un dump de la base de données
kubectl exec -n mysql-app mysql-0 -- mysqldump -uroot -p'MySecureP@ssw0rd2024!' businessdb > backup.sql

# Restaurer depuis un dump
kubectl exec -i -n mysql-app mysql-0 -- mysql -uroot -p'MySecureP@ssw0rd2024!' businessdb < backup.sql
```

## 🗑️ Nettoyage

### Méthode automatique

```bash
./deploy-mysql.sh cleanup
```

### Méthode manuelle

```bash
# Supprimer les services
kubectl delete -f 04-services.yaml

# Supprimer le StatefulSet
kubectl delete -f 03-statefulset.yaml

# Supprimer le ConfigMap
kubectl delete -f 02-configmap.yaml

# Supprimer les secrets
kubectl delete -f 01-secret.yaml

# Supprimer les PVCs (ATTENTION: perte des données)
kubectl delete pvc -n mysql-app --all

# Supprimer le namespace
kubectl delete -f 00-namespace.yaml
```

## ⚠️ Important - Problèmes identifiés

### Fichier 03-statefulset.yaml original

Le fichier original contient des erreurs dans les probes :
- `livenessProbe` : Manque le mot de passe pour `mysqladmin`
- `readinessProbe` : Manque les credentials MySQL

**Solution** : Utiliser `03-statefulset-fixed.yaml`

```bash
cp 03-statefulset-fixed.yaml 03-statefulset.yaml
```

Consultez `ANALYSE_COHERENCE.md` pour plus de détails.

## 🔒 Sécurité

### Pour la production

❌ **NE PAS FAIRE** :
- Utiliser le service NodePort (désactiver ou supprimer)
- Laisser les mots de passe en clair dans les fichiers
- Utiliser des secrets Kubernetes sans chiffrement

✅ **À FAIRE** :
- Utiliser un LoadBalancer ou Ingress avec TLS
- Utiliser un gestionnaire de secrets externe (Vault, AWS Secrets Manager)
- Configurer des Network Policies
- Activer le chiffrement des données au repos
- Mettre en place des backups réguliers
- Configurer la réplication MySQL

## 📈 Scaling et Haute Disponibilité

Pour passer en production avec haute disponibilité :

1. **Augmenter les replicas** (nécessite la configuration master-slave)
```yaml
spec:
  replicas: 3
```

2. **Ajouter un pod de backup automatique**
3. **Configurer le monitoring** (Prometheus + Grafana)
4. **Mettre en place des alertes**

## 📚 Ressources

- [Documentation Kubernetes StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [MySQL Docker Hub](https://hub.docker.com/_/mysql)
- [Best Practices MySQL sur Kubernetes](https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/)

## 🐛 Dépannage

### Le pod ne démarre pas

```bash
# Vérifier les logs
kubectl logs -n mysql-app mysql-0

# Vérifier les événements
kubectl describe pod mysql-0 -n mysql-app

# Vérifier le PVC
kubectl get pvc -n mysql-app
```

### Erreur de connexion

```bash
# Vérifier que le pod est ready
kubectl get pods -n mysql-app

# Tester depuis le pod
kubectl exec -n mysql-app mysql-0 -- mysqladmin ping -h localhost -pMySecureP@ssw0rd2024!
```

### Problème de stockage

```bash
# Vérifier la StorageClass
kubectl get storageclass

# Vérifier le PV
kubectl get pv

# Vérifier les PVC
kubectl get pvc -n mysql-app
```

## 📞 Support

Pour toute question ou problème :
1. Consultez `ANALYSE_COHERENCE.md` pour l'analyse détaillée
2. Vérifiez les logs : `kubectl logs -n mysql-app mysql-0`
3. Utilisez : `./deploy-mysql.sh status` pour le diagnostic

---

**Version** : 1.0  
**Dernière mise à jour** : 2024
