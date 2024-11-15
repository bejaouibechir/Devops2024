## **Étape 1 : Configurer l'accès à votre cluster Kubernetes**
Avant de connecter Jenkins, vous devez vous assurer que votre Jenkins a les droits d'accès au cluster.

1. **Configurer `kubeconfig` pour Jenkins** :
   - Sur la machine Jenkins ou sur votre poste local, configurez `kubectl` pour interagir avec votre cluster EKS :
     ```bash
     aws eks --region <region> update-kubeconfig --name <cluster_name>
     ```
   - Testez la connectivité :
     ```bash
     kubectl get nodes
     ```
     Vous devriez voir les nœuds de votre cluster.

2. **Obtenir les informations nécessaires pour Jenkins** :
   - **Kubernetes API Server** : Obtenez l’URL de l’API server Kubernetes avec :
     ```bash
     kubectl cluster-info
     ```
     Vous aurez une sortie comme :
     ```
     Kubernetes control plane is running at https://<api-server-url>
     ```
   - **Token d'accès** : Suivez les étapes précédentes pour extraire un **token secret Kubernetes** (lié au service Jenkins).

---

## **Étape 2 : Installer le plugin Kubernetes dans Jenkins**
1. **Accédez à Jenkins** :
   - Connectez-vous à l'interface Jenkins avec un compte administrateur.

2. **Installer le plugin Kubernetes** :
   - Allez dans **Manage Jenkins > Plugin Manager > Available plugins**.
   - Recherchez le plugin **"Kubernetes"** et installez-le.

---

## **Étape 3 : Configurer Kubernetes dans Jenkins**
1. **Ajouter un Cloud Kubernetes dans Jenkins** :
   - Allez dans **Manage Jenkins > Configure System**.
   - Dans la section **Cloud**, cliquez sur **Add a new cloud** > **Kubernetes**.

2. **Configurer les détails Kubernetes** :
   - **Kubernetes URL** : Collez l’URL de votre API Kubernetes obtenue avec `kubectl cluster-info`.
   - **Kubernetes Namespace** : Généralement, utilisez le namespace `default` ou un namespace dédié à Jenkins.
   - **Kubeconfig file** : Ajoutez le contenu de votre fichier `~/.kube/config` ou utilisez une URL directe.

3. **Ajouter les Credentials** :
   - Dans Jenkins, allez dans **Manage Jenkins > Credentials**.
   - Ajoutez un nouveau **Secret Text Credential** contenant le **token** Kubernetes (obtenu précédemment) :
     - ID : `kubernetes-token`
     - Secret : Le token Kubernetes.

4. **Associer les Credentials** :
   - Retournez dans la configuration du cloud Kubernetes.
   - Dans **Kubernetes Service Account**, choisissez l'ID des credentials que vous venez de créer (`kubernetes-token`).

---

## **Étape 4 : Créer un pipeline Jenkins pour déployer sur Kubernetes**
1. **Configurer un fichier `Jenkinsfile` pour votre pipeline** :
   Voici un exemple de pipeline qui déploie une application sur Kubernetes :
   ```groovy
   pipeline {
       agent any
       stages {
           stage('Deploy to Kubernetes') {
               steps {
                   script {
                       // Assurez-vous que 'kubectl' est disponible dans votre environnement Jenkins
                       sh '''
                       echo "$KUBECONFIG" > kubeconfig
                       export KUBECONFIG=kubeconfig
                       kubectl apply -f deployment.yaml
                       '''
                   }
               }
           }
       }
   }
   ```

2. **Ajoutez `kubectl` au conteneur Jenkins (si nécessaire)** :
   - Si vous utilisez Jenkins dans un conteneur Docker, assurez-vous que l'image contient `kubectl`.
   - Si ce n’est pas le cas, installez-le :
     ```bash
     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
     chmod +x kubectl
     sudo mv kubectl /usr/local/bin/
     ```

---

## **Étape 5 : Vérification**
- Testez le pipeline en exécutant une tâche Jenkins qui applique un fichier `deployment.yaml` sur le cluster.
- Vérifiez l'état du cluster après le déploiement :
  ```bash
  kubectl get pods
  ```

---

### **Résumé des configurations dans Jenkins**
1. Installez le plugin **Kubernetes** dans Jenkins.
2. Configurez un **Kubernetes Cloud** avec l'URL API du cluster et les credentials.
3. Ajoutez un pipeline Jenkins avec `kubectl` pour gérer vos déploiements.
