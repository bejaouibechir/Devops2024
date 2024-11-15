### **1. Préparation de l’environnement**

1. **Créer un compte AWS ou utiliser un compte existant.**
   - Connectez-vous à la console AWS avec les droits du compte racine.

2. **Installer les outils nécessaires sur votre machine locale :**
   - **AWS CLI** : Permet de communiquer avec les services AWS.
     ```bash
     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
     unzip awscliv2.zip
     sudo ./aws/install
     aws --version
     ```
   - **kubectl** : Gestion du cluster Kubernetes.
     ```bash
     curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
     chmod +x kubectl
     sudo mv kubectl /usr/local/bin/
     kubectl version --client
     ```
   - **eksctl** : Outil pour créer et gérer des clusters EKS.
     ```bash
     curl -LO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz"
     tar -xvf eksctl_Linux_amd64.tar.gz
     sudo mv eksctl /usr/local/bin/
     eksctl version
     ```

---

### **2. Configuration du compte AWS avec AWS CLI**

1. **Configurer les identifiants du compte racine AWS :**
   - Exécutez la commande :
     ```bash
     aws configure
     ```
   - Entrez les informations suivantes :
     - **AWS Access Key ID** : Clé générée pour le compte racine.
     - **AWS Secret Access Key** : Clé secrète associée.
     - **Default region name** : Région pour le cluster (ex. `eu-west-1` pour l'Irlande).
     - **Default output format** : Format des résultats (ex. `json` ou `yaml`).

2. **Tester la configuration :**
   - Vérifiez les informations du compte configuré :
     ```bash
     aws sts get-caller-identity
     ```

---

### **3. Créer un rôle IAM pour EKS**

1. **Accéder à la console IAM AWS :**
   - **IAM > Roles > Create Role**.

2. **Configurer le rôle IAM :**
   - **Trusted entity type** : Sélectionnez **AWS service**.
   - **Use case** : Sélectionnez **EKS - Service**.
   - **Permissions** : Associez les politiques suivantes :
     - `AmazonEKSClusterPolicy`
     - `AmazonEKSServicePolicy`
   - Nommez le rôle, par exemple, `EKS-ClusterRole`.

3. **Créer un autre rôle IAM pour les nœuds du cluster (node group) :**
   - Répétez les étapes ci-dessus et associez ces politiques :
     - `AmazonEKSWorkerNodePolicy`
     - `AmazonEC2ContainerRegistryReadOnly`
     - `AmazonEKS_CNI_Policy`
   - Nommez le rôle, par exemple, `EKS-NodeRole`.

---

### **4. Créer le cluster EKS avec eksctl**

1. **Créer un cluster avec eksctl :**
   - Commande pour un cluster de base :
     ```bash
     eksctl create cluster \
       --name my-eks-cluster \
       --region eu-west-1 \
       --nodegroup-name my-node-group \
       --node-type t2.micro \
       --nodes 2 \
       --nodes-min 1 \
       --nodes-max 3 \
       --managed
     ```

   - Cette commande :
     - Crée un cluster Kubernetes nommé `my-eks-cluster`.
     - Déploie un **node group** (groupe de nœuds gérés).
     - Utilise des instances EC2 `t2.micro` (faible coût).

2. **Vérifiez que le cluster est actif :**
   ```bash
   eksctl get cluster --region eu-west-1
   ```

---

### **5. Configurer `kubectl` pour interagir avec le cluster**

1. **Récupérez le contexte du cluster pour `kubectl` :**
   ```bash
   aws eks --region eu-west-1 update-kubeconfig --name my-eks-cluster
   ```

2. **Vérifiez les nœuds du cluster :**
   ```bash
   kubectl get nodes
   ```

---

### **6. Déployer une application sur le cluster**

1. **Déployez un pod de test :**
   ```bash
   kubectl create deployment nginx --image=nginx
   ```

2. **Exposez le pod avec un service :**
   ```bash
   kubectl expose deployment nginx --type=LoadBalancer --port=80
   ```

3. **Vérifiez l’état du service :**
   ```bash
   kubectl get svc
   ```

4. Accédez à l'application via l'adresse `EXTERNAL-IP` obtenue.

---

### **7. Supprimer le cluster**

1. **Détruire le cluster et les ressources associées :**
   ```bash
   eksctl delete cluster --name my-eks-cluster --region eu-west-1
   ```

2. **Vérifiez que toutes les ressources sont supprimées.**

---

### **Résumé des étapes importantes :**

1. **Configurer AWS CLI avec les identifiants racine.**
2. **Créer des rôles IAM pour le cluster et les nœuds.**
3. **Utiliser `eksctl` pour créer un cluster avec un node group.**
4. **Configurer `kubectl` pour interagir avec le cluster.**
5. **Tester avec une application (ex. nginx).**
6. **Supprimer le cluster pour éviter des frais inutiles.**

