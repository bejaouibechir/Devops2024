#  **Finalisation Labo 4 — Déploiement Kubernetes avec Helm**

# ** Nettoyer les ressources Kubernetes existantes**

```bash
kubectl delete deployment php mysql
kubectl delete service php-service mysql-service
kubectl delete pvc mysql-pvc
kubectl delete pv mysql-pv
kubectl delete configmap app-config
kubectl delete secret db-secret
```

>  Si tu veux tout nettoyer d'un coup (y compris les ressources orphelines) :

```bash
kubectl delete all --all
kubectl delete pvc --all
kubectl delete pv --all
kubectl delete configmap --all
kubectl delete secret --all
```

---

# ** Installer Helm**

## Sur Minikube

```bash
brew install helm         # si tu utilises Mac et Homebrew
```

ou sur Linux :

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

---

## Vérifier

```bash
helm version
```

---

#  ** Créer un Helm Chart**

##  Créer la structure du chart

```bash
helm create myapp
```

Cela crée un dossier :

```
myapp/
│
├── charts/
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── pvc.yaml
│   ├── pv.yaml
│   ├── configmap.yaml
│   └── secret.yaml
├── Chart.yaml
├── values.yaml
└── ...
```
##  Adapter `values.yaml`

**Exemple minimal pour tes variables :**

```yaml
mysql:
  rootPassword: "test123++"
  database: "businessdb"
  user: "test"
  password: "test123++"

persistence:
  enabled: true
  size: 1Gi
  path: "/mnt/data/mysql"

php:
  service:
    type: NodePort
    port: 80
    nodePort: 30080
```

---

## Adapter les templates

###  `templates/configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DB_NAME: {{ .Values.mysql.database }}
  DB_USER: {{ .Values.mysql.user }}
  DB_HOST: mysql-service
```

---

###  `templates/secret.yaml`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  DB_PASSWORD: {{ .Values.mysql.password | b64enc }}
  ROOT_PASSWORD: {{ .Values.mysql.rootPassword | b64enc }}
```

---

###  `templates/pv.yaml`

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: {{ .Values.persistence.size }}
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "{{ .Values.persistence.path }}"
```

---

###  `templates/pvc.yaml`

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.persistence.size }}
```
###  `templates/mysql-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:latest
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: ROOT_PASSWORD
            - name: MYSQL_DATABASE
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: DB_NAME
            - name: MYSQL_USER
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: DB_USER
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: DB_PASSWORD
          ports:
            - containerPort: 3306
          volumeMounts:
            - mountPath: /var/lib/mysql
              name: mysql-storage
      volumes:
        - name: mysql-storage
          persistentVolumeClaim:
            claimName: mysql-pvc
```


###  `templates/mysql-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
spec:
  selector:
    app: mysql
  ports:
    - protocol: TCP
      port: 3306
      targetPort: 3306
  clusterIP: None
```

---

###  `templates/php-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php
  template:
    metadata:
      labels:
        app: php
    spec:
      containers:
        - name: php
          image: php-app-image:latest
          ports:
            - containerPort: 80
          env:
            - name: DB_SERVER
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: DB_HOST
            - name: DB_NAME
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: DB_NAME
            - name: DB_USER
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: DB_USER
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: DB_PASSWORD
```

###  `templates/php-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: php-service
spec:
  type: {{ .Values.php.service.type }}
  selector:
    app: php
  ports:
    - port: {{ .Values.php.service.port }}
      targetPort: 80
      nodePort: {{ .Values.php.service.nodePort }}
```

---

# ** Appliquer le Helm Chart**

## Se placer dans le dossier du chart

```bash
cd myapp
```

---

## Installer (ou upgrade si déjà installé)

```bash
helm install myapp .
```

ou

```bash
helm upgrade myapp . --install
```

---

## Vérifier

```bash
kubectl get all
```

---

## Accéder à l'application

```bash
minikube service php-service
```


#  **🎉 Résultat final**

Tout est factorisé :

* ConfigMap & Secret dynamiques
* PV/PVC inclus
* Services et déploiements orchestrés
* Helm = facile à reconfigurer, versionner, et déployer



## 💬 **Conclusion**

🎯 Avec Helm, tu transformes ton projet en **vrai package réutilisable**, prêt pour des environnements dev, staging ou prod.
