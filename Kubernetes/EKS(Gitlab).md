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

Avec ces étapes, vous pouvez connecter manuellement votre cluster EKS à GitLab et déployer vos applications directement via vos pipelines CI/CD. Si vous avez des questions, faites-le-moi savoir ! 🚀
