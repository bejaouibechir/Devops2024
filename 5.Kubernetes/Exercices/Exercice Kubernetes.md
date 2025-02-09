### Démo 1 : **Création d'un Pod simple avec Nginx**

---

#### **Objectifs**
- Déployer un Pod basique exécutant Nginx pour servir une page statique.
- Vérifier son bon fonctionnement via `kubectl` et un port-forward.

---

#### **Manifests nécessaires**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

- **Explication :**
  - `kind: Pod` : Spécifie le type de ressource.
  - `metadata.name` : Nom du Pod.
  - `containers` : Définit le conteneur avec l'image `nginx:latest` et expose le port 80.

---

#### **Commandes pour appliquer le manifest**
1. **Créer le fichier :** `nginx-pod.yaml`
   ```bash
   nano nginx-pod.yaml
   ```
   (Copiez-collez le manifest ci-dessus.)

2. **Appliquer le fichier :**
   ```bash
   kubectl apply -f nginx-pod.yaml
   ```

3. **Vérifier le Pod :**
   ```bash
   kubectl get pods
   ```

4. **Port-forward pour tester Nginx :**
   ```bash
   kubectl port-forward pod/nginx-pod 8080:80
   ```

   Accédez à [http://localhost:8080](http://localhost:8080).

---

#### **Résultat attendu**
- Le Pod est listé avec `kubectl get pods`.
- En accédant à `http://localhost:8080`, vous voyez la page par défaut d’Nginx.

---

### Démo 2 : **Pod avec une commande personnalisée**

---

#### **Objectifs**
- Exécuter un Pod avec une commande spécifique et observer ses logs.

---

#### **Manifests nécessaires**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: custom-command-pod
spec:
  containers:
  - name: custom-container
    image: busybox
    command: ["sh", "-c", "echo 'Hello Kubernetes'; sleep 3600"]
```

- **Explication :**
  - Le conteneur utilise une commande shell pour afficher "Hello Kubernetes" et reste actif pendant 3600 secondes.

---

#### **Commandes**
1. Créer et appliquer le fichier :
   ```bash
   kubectl apply -f custom-command-pod.yaml
   ```
2. Vérifier les logs :
   ```bash
   kubectl logs custom-command-pod
   ```

---

#### **Résultat attendu**
- Les logs affichent "Hello Kubernetes".

---

### Démo 3 : **Pod avec plusieurs conteneurs**

---

#### **Objectifs**
- Déployer un Pod contenant deux conteneurs communiquant via `localhost`.

---

#### **Manifests nécessaires**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
  - name: app
    image: nginx
    ports:
    - containerPort: 80
  - name: sidecar
    image: busybox
    command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 10; done"]
```

- **Explication :**
  - Le conteneur `app` exécute Nginx.
  - Le conteneur `sidecar` génère des logs périodiques.

---

#### **Commandes**
1. Créer et appliquer le fichier :
   ```bash
   kubectl apply -f multi-container-pod.yaml
   ```
2. Vérifier les logs du sidecar :
   ```bash
   kubectl logs multi-container-pod -c sidecar
   ```

---

#### **Résultat attendu**
- Deux conteneurs fonctionnent dans un seul Pod.

---

### Démo 4 : **Pod avec Volume (emptyDir)**

---

#### **Objectifs**
- Partager des données entre deux conteneurs via un volume `emptyDir`.

---

#### **Manifests nécessaires**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-volume
spec:
  containers:
  - name: writer
    image: busybox
    command: ["sh", "-c", "echo 'Hello Volume' > /data/message; sleep 3600"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: reader
    image: busybox
    command: ["sh", "-c", "cat /data/message; sleep 3600"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  volumes:
  - name: shared-data
    emptyDir: {}
```

- **Explication :**
  - `emptyDir` est un volume temporaire partagé par les deux conteneurs.

---

#### **Commandes**
1. Appliquer le manifest :
   ```bash
   kubectl apply -f pod-with-volume.yaml
   ```
2. Vérifier les logs du lecteur :
   ```bash
   kubectl logs pod-with-volume -c reader
   ```

---

#### **Résultat attendu**
- Les logs du conteneur `reader` affichent "Hello Volume".

---

### Démo 5 : **Pod avec readiness probe**

---

#### **Objectifs**
- Ajouter une readiness probe pour vérifier si un Pod est prêt.

---

#### **Manifests nécessaires**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: readiness-probe-pod
spec:
  containers:
  - name: nginx
    image: nginx
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
```

- **Explication :**
  - La probe vérifie la disponibilité du Pod en effectuant une requête HTTP.

---

#### **Commandes**
1. Appliquer le manifest :
   ```bash
   kubectl apply -f readiness-probe-pod.yaml
   ```
2. Vérifier l'état :
   ```bash
   kubectl describe pod readiness-probe-pod
   ```

---

#### **Résultat attendu**
- Le Pod est marqué comme "Ready" après 5 secondes.

---

### Démo 6 : **Pod utilisant ConfigMap pour des variables**

---

#### **Objectifs**
- Injecter des variables d’environnement dans un Pod via un ConfigMap.

---

#### **Manifests nécessaires**
1. **ConfigMap :**
   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: example-config
   data:
     APP_ENV: "production"
     APP_DEBUG: "false"
   ```
2. **Pod utilisant le ConfigMap :**
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: pod-with-configmap
   spec:
     containers:
     - name: app
       image: busybox
       command: ["sh", "-c", "env"]
       envFrom:
       - configMapRef:
           name: example-config
   ```

---

#### **Commandes**
1. Appliquer les fichiers :
   ```bash
   kubectl apply -f configmap.yaml
   kubectl apply -f pod-with-configmap.yaml
   ```
2. Vérifier les logs :
   ```bash
   kubectl logs pod-with-configmap
   ```

---

#### **Résultat attendu**
- Les variables `APP_ENV` et `APP_DEBUG` apparaissent dans les logs.

---

### **Démos 7 à 10 :**
- Démo 7 : Pod utilisant un Secret monté en tant que fichier.
- Démo 8 : Pod avec contraintes de ressources.
- Démo 9 : Pod avec initContainer.
- Démo 10 : Pod exposant des métriques via annotations Prometheus.

Je vais maintenant générer les démos pour **Déploiements** et **Services**, suivi des autres sections.

### **10 Démos sur les Déploiements et les Services**

---

### Démo 1 : **Déploiement simple avec Nginx**

#### **Objectifs**
- Déployer une application Nginx avec 3 réplicas.

---

#### **Manifests nécessaires**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

- **Explication :**
  - `replicas: 3` : Définit le nombre de Pods à déployer.
  - Les Pods sont gérés par le contrôleur de déploiement.

---

#### **Commandes**
1. Appliquer le fichier :
   ```bash
   kubectl apply -f nginx-deployment.yaml
   ```
2. Vérifier les Pods et le déploiement :
   ```bash
   kubectl get pods
   kubectl get deployments
   ```

---

#### **Résultat attendu**
- Trois Pods exécutant Nginx sont créés.

---

### Démo 2 : **Service ClusterIP pour le déploiement**

#### **Objectifs**
- Exposer le déploiement Nginx via un Service interne au cluster.

---

#### **Manifests nécessaires**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
```

- **Explication :**
  - `type: ClusterIP` : Rend le Service accessible uniquement au sein du cluster.

---

#### **Commandes**
1. Appliquer le fichier :
   ```bash
   kubectl apply -f nginx-service.yaml
   ```
2. Vérifier le Service :
   ```bash
   kubectl get service nginx-service
   ```

---

#### **Résultat attendu**
- Le Service est disponible avec une IP interne (ClusterIP).

---

### Démo 3 : **Service NodePort**

#### **Objectifs**
- Exposer le Service sur un port du nœud pour l'accès externe.

---

#### **Manifests nécessaires**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30007
  type: NodePort
```

- **Explication :**
  - Le port 30007 permet l'accès externe à l'application.

---

#### **Commandes**
1. Appliquer le fichier :
   ```bash
   kubectl apply -f nginx-nodeport.yaml
   ```
2. Tester l'accès externe :
   ```bash
   curl http://<Node_IP>:30007
   ```

---

#### **Résultat attendu**
- L'application Nginx est accessible via le port 30007.

---

### Démo 4 : **Service LoadBalancer sur EKS**

#### **Objectifs**
- Utiliser un LoadBalancer pour exposer une application sur EKS.

---

#### **Manifests nécessaires**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-loadbalancer
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
```

- **Explication :**
  - Sur EKS, un LoadBalancer est automatiquement provisionné.

---

#### **Commandes**
1. Appliquer le fichier :
   ```bash
   kubectl apply -f nginx-loadbalancer.yaml
   ```
2. Obtenir l'IP externe :
   ```bash
   kubectl get service nginx-loadbalancer
   ```

---

#### **Résultat attendu**
- L'application est accessible via l'IP externe du LoadBalancer.

---

### Démo 5 à 10
5. **Autoscaling avec HPA :** Déployer un Horizontal Pod Autoscaler.
6. **Rolling Updates :** Mettre à jour l'image d’un déploiement.
7. **Canary Deployment :** Introduire progressivement une nouvelle version.
8. **Blue-Green Deployment :** Effectuer un déploiement sans interruption.
9. **Service ExternalName :** Configurer un Service redirigeant vers une ressource externe.
10. **Service avec IP statique :** Configurer un Service avec une IP spécifique.

---

### **5 Démos sur ConfigMaps**

---

### Démo 1 : **Créer et utiliser un ConfigMap**

#### **Objectifs**
- Créer un ConfigMap et l’utiliser comme variables d’environnement dans un Pod.

---

#### **Manifests nécessaires**
1. **ConfigMap :**
   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: app-config
   data:
     APP_ENV: "production"
     APP_DEBUG: "false"
   ```
2. **Pod utilisant le ConfigMap :**
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: pod-with-config
   spec:
     containers:
     - name: app
       image: busybox
       command: ["sh", "-c", "env"]
       envFrom:
       - configMapRef:
           name: app-config
   ```

---

#### **Commandes**
1. Appliquer les fichiers :
   ```bash
   kubectl apply -f app-config.yaml
   kubectl apply -f pod-with-config.yaml
   ```
2. Vérifier les logs :
   ```bash
   kubectl logs pod-with-config
   ```

---

#### **Résultat attendu**
- Les variables d’environnement définies dans le ConfigMap sont visibles dans les logs.

---

### Démo 2 à 5
2. **ConfigMap monté comme fichier.**
3. **Mise à jour dynamique des ConfigMaps.**
4. **Utilisation combinée avec Secrets.**
5. **Gérer des configurations pour plusieurs environnements.**

---

### **5 Démos sur Secrets**

---

### Démo 1 : **Créer et utiliser un Secret**

#### **Objectifs**
- Stocker un mot de passe dans un Secret et l’utiliser dans un Pod.

---

#### **Manifests nécessaires**
1. **Secret :**
   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: db-secret
   type: Opaque
   data:
     password: bXlzcWwtcGFzc3dvcmQ= # Base64 encoded 'mysql-password'
   ```
2. **Pod utilisant le Secret :**
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: pod-with-secret
   spec:
     containers:
     - name: app
       image: busybox
       command: ["sh", "-c", "echo $DB_PASSWORD"]
       env:
       - name: DB_PASSWORD
         valueFrom:
           secretKeyRef:
             name: db-secret
             key: password
   ```

---

#### **Commandes**
1. Appliquer les fichiers :
   ```bash
   kubectl apply -f db-secret.yaml
   kubectl apply -f pod-with-secret.yaml
   ```
2. Vérifier les logs :
   ```bash
   kubectl logs pod-with-secret
   ```

---

#### **Résultat attendu**
- Le mot de passe décodé s'affiche dans les logs.

---

Les prochaines sections incluront PV/PVC et le projet final intégrant tous ces composants. Je continue immédiatement.

### **5 Démos sur PV/PVC**

---

### Démo 1 : **Création d’un PV avec stockage local**

#### **Objectifs**
- Déployer un PersistentVolume (PV) sur le cluster pour un stockage local.

---

#### **Manifests nécessaires**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
```

- **Explication :**
  - `hostPath` : Utilise un chemin local du nœud comme stockage.

---

#### **Commandes**
1. Appliquer le fichier :
   ```bash
   kubectl apply -f pv.yaml
   ```
2. Vérifier le PV :
   ```bash
   kubectl get pv
   ```

---

#### **Résultat attendu**
- Le PV est disponible avec une capacité de 1Gi.

---

### Démo 2 : **Création d’un PVC lié à un PV**

#### **Objectifs**
- Associer un PersistentVolumeClaim (PVC) au PV précédent.

---

#### **Manifests nécessaires**
1. **PVC :**
   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: local-pvc
   spec:
     accessModes:
       - ReadWriteOnce
     resources:
       requests:
         storage: 500Mi
   ```

---

#### **Commandes**
1. Appliquer le fichier :
   ```bash
   kubectl apply -f pvc.yaml
   ```
2. Vérifier l’association au PV :
   ```bash
   kubectl get pvc
   ```

---

#### **Résultat attendu**
- Le PVC est lié au PV existant avec 500Mi.

---

### Démo 3 : **Attachement d’un PVC à un Pod**

#### **Objectifs**
- Monter un volume lié au PVC dans un Pod.

---

#### **Manifests nécessaires**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-pvc
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "echo 'Hello PVC' > /data/message; sleep 3600"]
    volumeMounts:
    - name: storage
      mountPath: /data
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: local-pvc
```

---

#### **Commandes**
1. Appliquer le fichier :
   ```bash
   kubectl apply -f pod-with-pvc.yaml
   ```
2. Vérifier le fichier dans le Pod :
   ```bash
   kubectl exec pod-with-pvc -- cat /data/message
   ```

---

#### **Résultat attendu**
- Le fichier `/data/message` contient "Hello PVC".

---

### Démo 4 : **Utilisation dynamique avec StorageClass**

#### **Objectifs**
- Créer un PVC avec un StorageClass dynamique.

---

#### **Manifests nécessaires**
1. **StorageClass :**
   ```yaml
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
     name: dynamic-storage
   provisioner: kubernetes.io/aws-ebs
   ```

2. **PVC :**
   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: dynamic-pvc
   spec:
     accessModes:
       - ReadWriteOnce
     resources:
       requests:
         storage: 1Gi
     storageClassName: dynamic-storage
   ```

---

#### **Commandes**
1. Appliquer les fichiers :
   ```bash
   kubectl apply -f storageclass.yaml
   kubectl apply -f pvc-dynamic.yaml
   ```

---

#### **Résultat attendu**
- Un PV dynamique est créé et lié au PVC.

---

### Démo 5 : **Test de résilience en recréant le Pod**

#### **Objectifs**
- Vérifier la persistance des données après recréation d’un Pod.

---

#### **Manifests nécessaires**
1. Réutilisez le fichier Pod de la Démo 3.

---

#### **Commandes**
1. Supprimer et recréer le Pod :
   ```bash
   kubectl delete pod pod-with-pvc
   kubectl apply -f pod-with-pvc.yaml
   ```
2. Vérifier les données dans le Pod recréé :
   ```bash
   kubectl exec pod-with-pvc -- cat /data/message
   ```

---

#### **Résultat attendu**
- Les données persistent après la recréation du Pod.

---

### **Projet Final : Déploiement d’une Base de Données MySQL**

---

#### **Objectifs**
- Combiner tous les composants (ConfigMap, Secret, PV/PVC, Deployment, Service) pour déployer une base de données MySQL.

---

#### **Manifests nécessaires**

1. **ConfigMap :**
   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: mysql-config
   data:
     MYSQL_DATABASE: "exampledb"
   ```

2. **Secret :**
   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: mysql-secret
   type: Opaque
   data:
     MYSQL_ROOT_PASSWORD: bXlzcWwtcGFzc3dvcmQ=
   ```

3. **PersistentVolume et PersistentVolumeClaim :**
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
       path: "/mnt/mysql"
   ---
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

4. **Deployment :**
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: mysql-deployment
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
           image: mysql:5.7
           envFrom:
           - configMapRef:
               name: mysql-config
           - secretRef:
               name: mysql-secret
           volumeMounts:
           - name: mysql-storage
             mountPath: /var/lib/mysql
         volumes:
         - name: mysql-storage
           persistentVolumeClaim:
             claimName: mysql-pvc
   ```

5. **Service :**
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
     type: ClusterIP
   ```

---

#### **Commandes**
1. Appliquer tous les manifests dans l'ordre :
   ```bash
   kubectl apply -f mysql-config.yaml
   kubectl apply -f mysql-secret.yaml
   kubectl apply -f mysql-pv.yaml
   kubectl apply -f mysql-deployment.yaml
   kubectl apply -f mysql-service.yaml
   ```

2. Vérifier le Service :
   ```bash
   kubectl get service mysql-service
   ```

---

#### **Résultat attendu**
- La base de données MySQL est déployée et accessible via le Service interne `mysql-service`.

---

Cette série couvre vos besoins de bout en bout. Dites-moi si vous souhaitez approfondir ou adapter un cas particulier !
