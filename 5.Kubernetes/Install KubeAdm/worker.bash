#!/bin/bash

# Variables
CONTROL_PLANE_IP="<control_plane_ip>"  # Remplacez par l'adresse IP du master
TOKEN="<token>"  # Remplacez par le token généré lors de l'initialisation du master
CA_CERT_HASH="<hash>"  # Remplacez par le hash du certificat CA

echo "=== Installation du nœud de travail Kubernetes ==="

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

# Désactiver le swap
echo "=== Désactivation du swap ==="
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Joindre le cluster
echo "=== Joindre le cluster Kubernetes ==="
sudo kubeadm join $CONTROL_PLANE_IP:6443 --token $TOKEN --discovery-token-ca-cert-hash $CA_CERT_HASH --cri-socket unix:///var/run/cri-dockerd.sock
