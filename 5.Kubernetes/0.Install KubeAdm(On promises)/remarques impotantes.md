# Remarques importantes 

Pour éviter que le cluster disfonctionne

- désactiver le swap d'une manière permanente sur /etc/fstab sur le master et le worker les deux
- Etre sur que le kubelet et container d sont en marche via **sudo systemctl status kubelet** ou **sudo systemctl status container-d**
- Etre sur que le composant réseau est installé
       - curl https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml -O
       -  kubectl apply -f calico.yaml
       - kubectl get pods -n kube-system -o wide
- Indiquer au niveau init que le réseau est bien indiqué exemple **sudo kubeadm init --pod-network-cidr=192.168.0.0/16**
- Etre sûr que les ports nécessaires sont ouverts telque 6443 
