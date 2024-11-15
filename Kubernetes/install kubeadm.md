Voici le guide complet, mis à jour avec la remarque importante sur `<control_plane_ip>` :

---

### **Étapes détaillées :**

#### 1. **Installer Docker et `cri-dockerd`**
Docker est utilisé comme runtime, et `cri-dockerd` permet son intégration avec Kubernetes.

1. Ajouter la clé GPG pour Docker :
   ```bash
   wget -O - https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   ```

2. Ajouter le dépôt Docker :
   ```bash
   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
   sudo apt-get update
   ```

3. Installer Docker :
   ```bash
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io
   ```

4. Installer `cri-dockerd` :
   ```bash
   VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest | grep tag_name | cut -d '"' -f 4)
   wget https://github.com/Mirantis/cri-dockerd/releases/download/$VER/cri-dockerd-$VER.amd64.tgz
   tar -xvf cri-dockerd-$VER.amd64.tgz
   sudo mv cri-dockerd/cri-dockerd /usr/local/bin/
   ```

5. Configurer et activer `cri-dockerd` :
   ```bash
   wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
   wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
   sudo mv cri-docker.service cri-docker.socket /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable cri-docker.service
   sudo systemctl start cri-docker.service
   ```

---

#### 2. **Configurer Kubernetes**

1. Ajouter la clé GPG et le dépôt Kubernetes :
   ```bash
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
   echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
   ```

2. Mettre à jour les dépôts et installer Kubernetes :
   ```bash
   sudo apt-get update
   sudo apt-get install -y kubelet kubeadm kubectl
   sudo apt-mark hold kubelet kubeadm kubectl
   ```

3. Configurer les modules du noyau nécessaires :
   ```bash
   cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
   overlay
   br_netfilter
   EOF
   sudo modprobe overlay
   sudo modprobe br_netfilter
   ```

4. Configurer les paramètres réseau :
   ```bash
   cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
   net.bridge.bridge-nf-call-iptables  = 1
   net.bridge.bridge-nf-call-ip6tables = 1
   net.ipv4.ip_forward                 = 1
   EOF
   sudo sysctl --system
   ```

5. Désactiver le swap :
   ```bash
   sudo swapoff -a
   sudo sed -i '/ swap / s/^/#/' /etc/fstab
   ```

---

#### 3. **Initialiser le cluster Kubernetes**

1. Initialiser le cluster avec `kubeadm` :
   ```bash
   sudo kubeadm init --apiserver-advertise-address=<control_plane_ip> --cri-socket unix:///var/run/cri-dockerd.sock --pod-network-cidr=10.244.0.0/16
   ```

   **⚠ Remarque importante :**
   - Remplacez `<control_plane_ip>` par **l'adresse IP locale de votre machine**.  
     Pour obtenir l'IP locale :
     ```bash
     hostname -I | awk '{print $1}'
     ```
   - Par exemple, si l'adresse IP est `192.168.1.100`, la commande devient :
     ```bash
     sudo kubeadm init --apiserver-advertise-address=192.168.1.100 --cri-socket unix:///var/run/cri-dockerd.sock --pod-network-cidr=10.244.0.0/16
     ```

2. Configurer `kubectl` pour l'utilisateur actuel :
   ```bash
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   ```

3. Installer le plugin réseau Calico :
   ```bash
   kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml
   curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/custom-resources.yaml
   kubectl create -f custom-resources.yaml
   ```

4. Autoriser le scheduling sur le nœud maître (si cluster à nœud unique) :
   ```bash
   kubectl taint nodes --all node-role.kubernetes.io/control-plane-
   ```

---

#### 4. **Joindre des nœuds au cluster**

Si vous avez des nœuds supplémentaires :
1. Copier la commande join générée lors de l'initialisation :
   ```bash
   kubeadm token create --print-join-command
   ```

2. Exécuter la commande join sur les nœuds avec `cri-dockerd` :
   ```bash
   kubeadm join <control_plane_ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash> --cri-socket unix:///var/run/cri-dockerd.sock
   ```

---

#### 5. **Vérifier l'état du cluster**

1. Vérifier les nœuds :
   ```bash
   kubectl get nodes
   ```

2. Vérifier les pods :
   ```bash
   kubectl get pods --all-namespaces
   ```

---

### **Conclusion**
Ce guide inclut tout ce qui est nécessaire pour une installation manuelle complète de Kubernetes avec Docker et `cri-dockerd`. La remarque sur `<control_plane_ip>` garantit que la configuration réseau est correcte pour votre machine.

