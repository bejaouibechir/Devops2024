### **1. Préparation de l’environnement**

1. **Connectez-vous avec le compte racine AWS :**
   - Accédez à la console AWS via [AWS Management Console](https://aws.amazon.com/console/) avec vos identifiants **racine**.

2. **Installer les outils nécessaires sur votre machine :**
   - **AWS CLI** :
     ```bash
     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
     unzip awscliv2.zip
     sudo ./aws/install
     aws --version
     ```
   - **kubectl** :
     ```bash
     curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
     chmod +x kubectl
     sudo mv kubectl /usr/local/bin/
     kubectl version --client
     ```
   - **eksctl** :
     ```bash
     curl -LO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz"
     tar -xvf eksctl_Linux_amd64.tar.gz
     sudo mv eksctl /usr/local/bin/
     eksctl version
     ```

---

### **2. Configuration avec le compte racine**

1. **Configurer AWS CLI avec les clés racine :**
   - Utilisez les clés **Access Key ID** et **Secret Access Key** du compte racine.
   - Commande :
     ```bash
     aws configure
     ```
   - Entrez les informations suivantes :
     - **AWS Access Key ID** : La clé AWS générée pour le compte racine.
     - **AWS Secret Access Key** : La clé secrète associée.
     - **Default region name** : Exemple : `eu-west-1` (Irlande).
     - **Default output format** : Exemple : `json`.

2. **Tester la configuration :**
   - Assurez-vous que les identifiants racine sont actifs :
     ```bash
     aws sts get-caller-identity
     ```

---

### **3. Créer un cluster EKS avec eksctl**

1. **Lancer la commande `eksctl` pour créer le cluster :**
   - Exemple de commande pour créer un cluster avec deux nœuds EC2 :
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
   - **Explications :**
     - `--name my-eks-cluster` : Nom du cluster.
     - `--region eu-west-1` : Région AWS où créer le cluster.
     - `--node-type t2.micro` : Type d'instance EC2 (économique).
     - `--nodes 2` : Nombre initial de nœuds.
     - `--managed` : Indique qu'AWS gère le groupe de nœuds.

2. **Vérifiez que le cluster est actif :**
   ```bash
   eksctl get cluster --region eu-west-1
   ```

---

### **4. Configurer `kubectl` pour gérer le cluster**

1. **Récupérez la configuration du cluster pour `kubectl` :**
   ```bash
   aws eks --region eu-west-1 update-kubeconfig --name my-eks-cluster
   ```

2. **Vérifiez les nœuds du cluster :**
   ```bash
   kubectl get nodes
   ```

---

### **5. Déployer une application de test**

1. **Déployer un pod simple avec NGINX :**
   ```bash
   kubectl create deployment nginx --image=nginx
   ```

2. **Exposez le pod avec un service de type LoadBalancer :**
   ```bash
   kubectl expose deployment nginx --type=LoadBalancer --port=80
   ```

3. **Vérifiez que le service est actif :**
   ```bash
   kubectl get svc
   ```

4. **Accédez à l'application :**
   - Récupérez l'adresse `EXTERNAL-IP` affichée par la commande précédente.
   - Ouvrez l'adresse dans un navigateur.

---

### **6. Supprimer le cluster**

1. **Supprimer le cluster pour éviter les frais inutiles :**
   ```bash
   eksctl delete cluster --name my-eks-cluster --region eu-west-1
   ```

---

### **Résumé des étapes :**
1. **Préparez votre machine locale : Installez AWS CLI, kubectl, et eksctl.**
2. **Configurez AWS CLI avec les clés du compte racine.**
3. **Créez un cluster EKS avec eksctl.**
4. **Configurez kubectl pour interagir avec le cluster.**
5. **Déployez une application et vérifiez son fonctionnement.**
6. **Supprimez le cluster une fois terminé.**

