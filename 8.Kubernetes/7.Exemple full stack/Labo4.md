#  **Labo 4 — Déploiement Kubernetes avec Minikube (Approche incrémentielle)**

##   Phase 1 — Projet basique (2 déploiements + 2 services)**

##  Objectif

* 1 Déploiement MySQL + Service ClusterIP
* 1 Déploiement PHP + Service NodePort
* Pas encore de PV/PVC ni de ConfigMap/Secret

---

## Déploiement MySQL

**mysql-deployment.yaml**

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
              value: test123++
            - name: MYSQL_DATABASE
              value: businessdb
            - name: MYSQL_USER
              value: test
            - name: MYSQL_PASSWORD
              value: test123++
          ports:
            - containerPort: 3306
```

---

**mysql-service.yaml**

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

## Déploiement PHP

**php-deployment.yaml**

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
              value: mysql-service
            - name: DB_USERNAME
              value: test
            - name: DB_PASSWORD
              value: test123++
            - name: DB_NAME
              value: businessdb
```

---

**php-service.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: php-service
spec:
  type: NodePort
  selector:
    app: php
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

---

## Build image PHP (Minikube)

```bash
eval $(minikube docker-env)
docker build -t php-app-image ./src
```

---

## Appliquer

```bash
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml
kubectl apply -f php-deployment.yaml
kubectl apply -f php-service.yaml
```

---

##  Tester

```bash
minikube service php-service
```

---

#  ** Phase 2 — Ajouter persistance (PV + PVC)**

## Objectif

* Ajouter PV/PVC pour MySQL
* Toujours pas de ConfigMap ni Secret

---

##   Créer PV

**pv.yaml**

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data/mysql"
```

---

##  Créer PVC

**pvc.yaml**

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
      storage: 1Gi
```

---

##  Modifier le Déploiement MySQL

**mysql-deployment.yaml (mis à jour)**

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
              value: test123++
            - name: MYSQL_DATABASE
              value: businessdb
            - name: MYSQL_USER
              value: test
            - name: MYSQL_PASSWORD
              value: test123++
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

---

##  Appliquer

```bash
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f mysql-deployment.yaml
```

---

#  **Phase 3 — Externaliser avec ConfigMap et Secret**

##  Objectif

* Remplacer valeurs en dur par ConfigMap et Secret
* Finaliser l’architecture

---

##  Créer ConfigMap

**configmap.yaml**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DB_NAME: businessdb
  DB_USER: test
  DB_HOST: mysql-service
```

---

##   Créer Secret

**secret.yaml**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  DB_PASSWORD: dGVzdDEyMysr
  ROOT_PASSWORD: dGVzdDEyMysr
```

>  "test123++" → encodé en base64 → `dGVzdDEyMysr`

---

##   Modifier MySQL

**mysql-deployment.yaml (final)**

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

---

##  Modifier PHP

**php-deployment.yaml (final)**

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

---

## Appliquer

```bash
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f mysql-deployment.yaml
kubectl apply -f php-deployment.yaml
```

---

#  **Conclusion (vue finale)**

```
Phase 1 : 2 deployments + 2 services 
Phase 2 : + PV/PVC 
Phase 3 : + ConfigMap & Secret 
```

