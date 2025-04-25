## **Connecter un cluster Kubernetes à GitLab**

### **1. Utiliser des variables d'environnement**

Configurez les informations du cluster directement dans les variables CI/CD de votre projet.

#### **Étapes pour ajouter des variables CI/CD :**
1. **Accédez aux paramètres CI/CD :**
   - Dans votre projet GitLab, allez dans **Settings > CI/CD > Variables**.
   - Cliquez sur **Add variable** pour créer une nouvelle variable.

2. **Ajoutez les variables suivantes :**

   - **KUBECONFIG** : Contient le contenu de votre fichier kubeconfig.
     - Pour générer ce fichier, exécutez ces commandes dans votre Git Bash :
       ```bash
       aws eks --region <region> update-kubeconfig --name <cluster_name>
       cat ~/.kube/config
       ```
     - Copiez le contenu affiché dans le terminal et collez-le dans la variable **KUBECONFIG**.

   - **KUBE_TOKEN** : Ajoutez le token récupéré à partir du secret Kubernetes.
     - Pour obtenir ce token, exécutez les commandes suivantes :
       ```bash
       kubectl -n kube-system get secret | grep gitlab-sa
       ```
       - Recherchez le nom du secret lié à votre compte de service `gitlab-sa`.
       - Utilisez ce secret pour décrire le contenu et extraire le token :
         ```bash
         kubectl -n kube-system describe secret <secret_name>
         ```
       - Copiez la valeur du champ `token` et ajoutez-la à la variable **KUBE_TOKEN** dans GitLab.

   - **KUBE_API_URL** : Renseignez l'URL de l'API Kubernetes.
     - Pour obtenir cette URL, exécutez :
       ```bash
       kubectl cluster-info
       ```
     - Recherchez l'URL de l'API server, par exemple :
       ```
       https://<control-plane-endpoint>
       ```
     - Collez cette URL dans la variable **KUBE_API_URL**.

   - **KUBE_CA_CERT** : Ajoutez le certificat CA.
     - Exécutez la commande suivante pour extraire le certificat :
       ```bash
       kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode
       ```
     - Copiez la sortie et ajoutez-la dans la variable **KUBE_CA_CERT**.

---

### **2. Configurer un pipeline GitLab**

Une fois les variables CI/CD définies, configurez un pipeline `.gitlab-ci.yml` pour utiliser ces variables.

#### **Exemple de configuration de pipeline :**

```yaml
stages:
  - deploy

deploy:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - echo "$KUBECONFIG" > kubeconfig
    - export KUBECONFIG=kubeconfig
    - kubectl apply -f deployment.yaml
  only:
    - main
```

#### **Explications :**
- **`bitnami/kubectl:latest`** : Une image Docker contenant l'outil `kubectl` pour interagir avec Kubernetes.
- **`echo "$KUBECONFIG" > kubeconfig`** : Crée un fichier kubeconfig à partir de la variable.
- **`kubectl apply -f deployment.yaml`** : Applique votre fichier de déploiement Kubernetes.

---

### **Résumé des commandes importantes dans Git Bash**
- Générer et configurer `kubeconfig` :
  ```bash
  aws eks --region <region> update-kubeconfig --name <cluster_name>
  ```
- Obtenir le token Kubernetes :
  ```bash
  kubectl -n kube-system get secret | grep gitlab-sa
  kubectl -n kube-system describe secret <secret_name>
  ```
- Obtenir l'URL API du cluster :
  ```bash
  kubectl cluster-info
  ```
- Extraire le certificat CA :
  ```bash
  kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode
  ```

---


Voici les étapes détaillées pour obtenir le **token secret de Kubernetes** :

---

### **Étape 1 : Listez les secrets disponibles dans le namespace `kube-system`**
Utilisez la commande suivante pour lister tous les secrets disponibles dans le namespace `kube-system` :
```bash
kubectl -n kube-system get secret
```

Recherchez un secret associé au compte de service `gitlab-sa`. Le nom du secret sera quelque chose comme **`gitlab-sa-token-xxxxx`**.

---

### **Étape 2 : Obtenez le nom exact du secret**
Si vous souhaitez filtrer directement pour trouver le secret lié à `gitlab-sa`, utilisez la commande suivante :
```bash
kubectl -n kube-system get secret | grep gitlab-sa
```

La sortie affichera une ligne contenant le nom exact du secret, par exemple :
```
gitlab-sa-token-abcde   kubernetes.io/service-account-token   1      23m
```

Le nom du secret dans cet exemple est **`gitlab-sa-token-abcde`**.

---

### **Étape 3 : Décrivez le contenu du secret**
Utilisez la commande suivante pour voir les détails du secret et extraire le token :
```bash
kubectl -n kube-system describe secret <secret_name>
```

Par exemple :
```bash
kubectl -n kube-system describe secret gitlab-sa-token-abcde
```

Vous obtiendrez une sortie contenant un champ appelé **`token`**, comme ceci :
```
Name:         gitlab-sa-token-abcde
Namespace:    kube-system
Labels:       <none>
Annotations:  <annotations>

Type:  kubernetes.io/service-account-token

Data
====
namespace:  10 bytes
token:      eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
ca.crt:     1066 bytes
```

---

### **Étape 4 : Copiez le token**
- Copiez la valeur du champ **`token`**.
- C'est cette valeur que vous devez utiliser pour la variable **`KUBE_TOKEN`** dans GitLab.

---

### **Résumé des commandes**

1. Listez tous les secrets :
   ```bash
   kubectl -n kube-system get secret
   ```

2. Filtrez pour trouver le secret lié à `gitlab-sa` :
   ```bash
   kubectl -n kube-system get secret | grep gitlab-sa
   ```

3. Décrivez le secret pour extraire le token :
   ```bash
   kubectl -n kube-system describe secret <secret_name>
   ```


