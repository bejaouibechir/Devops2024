# Guide d'installation Kubernetes Single Node pour Ubuntu 22.04

Ce script permet d'installer un cluster Kubernetes à nœud unique sur Ubuntu 22.04. Il configure automatiquement Docker, cri-dockerd, kubeadm et Calico comme solution réseau.

## Prérequis
- Ubuntu 22.04 LTS
- Minimum 2 CPU
- Minimum 2 GB RAM
- Accès root/sudo
- Connexion Internet

## Installation

1. Créez un fichier `install-k8s.sh` :
```bash
wget https://raw.githubusercontent.com/votre-repo/install-k8s.sh
# ou copiez-collez le contenu du script dans un nouveau fichier
```

2. Rendez le script exécutable :
```bash
chmod +x install-k8s.sh
```

3. Exécutez le script :
```bash
./install-k8s.sh
```

## Que fait le script ?

1. Installation de Docker et configuration de cri-dockerd
2. Installation de Kubernetes (kubeadm, kubelet, kubectl)
3. Configuration du réseau (overlay, bridge)
4. Désactivation du swap
5. Initialisation du cluster avec Calico
6. Configuration pour l'utilisateur courant

## Vérification de l'installation

Après l'installation, vérifiez que tout fonctionne correctement :
```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

## Dépannage courant

1. Si les pods ne démarrent pas, vérifiez les logs :
```bash
kubectl describe pod <nom-du-pod> -n <namespace>
```

2. Pour vérifier l'état des services :
```bash
systemctl status kubelet
systemctl status cri-docker
```

3. Pour voir les logs du kubelet :
```bash
journalctl -u kubelet
```

## Maintien et mises à jour

Pour mettre à jour les composants Kubernetes :
```bash
sudo apt-get update
sudo apt-get upgrade kubelet kubeadm kubectl
```

## Sécurité

- Ce script configure un cluster basique. Pour la production, des configurations de sécurité supplémentaires sont nécessaires.
- Assurez-vous de sécuriser votre cluster selon vos besoins avant de l'utiliser en production.

## Contribuer

N'hésitez pas à contribuer à ce script en :
- Signalant des bugs
- Proposant des améliorations
- Ajoutant des fonctionnalités

## Licence

Ce script est partagé sous licence MIT. Vous êtes libre de l'utiliser et de le modifier selon vos besoins.

## Remerciements

Ce script est basé sur la documentation officielle de Kubernetes et les bonnes pratiques de la communauté.
