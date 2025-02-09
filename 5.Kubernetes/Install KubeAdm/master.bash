#!/bin/bash

# Variables
CONTROL_PLANE_IP=$(hostname -I | awk '{print $1}')
POD_NETWORK_CIDR="10.244.0.0/16"

echo "=== Installation du nœud maître Kubernetes ==="
echo "Adresse IP détectée : $CONTROL_PLANE_IP"
sleep 2

# Mise à jour du système et installation des dépendances
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

# Installation de Docker et cri-dockerd
echo "=== Installation de Docker ==="
wget -O - https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
echo "Docker installé avec succès."

echo "=== Installation de cri-dockerd ==="
VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest | grep tag_name | cut -d '"' -f 4)
wget https://github.com/Mirantis/cri-dockerd/releases/download/$VER/cri-dockerd-$VER.amd64.tgz
tar -xvf cri-dockerd-$VER.amd64.tgz
sudo mv cri-dockerd/cri-dockerd /usr/local/bin/
wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
sudo mv cri-docker.service cri-docker.socket /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl start cri-docker.service
echo "cri-dockerd installé et configuré avec succès."

# Installation de Kubernetes
echo "=== Installation de Kubernetes ==="
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Configurer le kernel
echo "=== Configuration des modules du noyau ==="
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# Désactiver le swap
echo "=== Désactivation du swap ==="
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Initialisation du cluster
echo "=== Initialisation du cluster Kubernetes ==="
sudo kubeadm init --apiserver-advertise-address=$CONTROL_PLANE_IP --cri-socket unix:///var/run/cri-dockerd.sock --pod-network-cidr=$POD_NETWORK_CIDR

# Configurer kubectl pour l'utilisateur actuel
echo "=== Configuration de kubectl ==="
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Installer Calico
echo "=== Installation du plugin réseau Calico ==="
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/custom-resources.yaml
kubectl create -f custom-resources.yaml

# Autoriser le scheduling sur le nœud maître (si nœud unique)
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
