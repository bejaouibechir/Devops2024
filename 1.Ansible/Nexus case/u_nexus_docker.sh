#!/bin/bash

set -e  # Arrêter le script en cas d'erreur

echo "---------------------------------- Suppression du conteneur Nexus ----------------------------------"
if sudo docker ps -a --format '{{.Names}}' | grep -q "nexus"; then
    sudo docker rm -f nexus
    echo "Nexus supprimé."
else
    echo "Aucun conteneur Nexus trouvé."
fi

echo "---------------------------------- Suppression du volume Nexus ----------------------------------"
sudo docker volume rm nexus-data || echo "Le volume Nexus n'existe pas."

echo "---------------------------------- Désinstallation de Docker ----------------------------------"
if command -v docker &> /dev/null; then
    sudo apt remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo apt autoremove -y
    echo "Docker désinstallé avec succès."
else
    echo "Docker n'est pas installé."
fi

echo "---------------------------------- Suppression des fichiers Docker ----------------------------------"
sudo rm -rf /var/lib/docker /etc/docker /var/lib/containerd
sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/docker.list

echo "---------------------------------- Suppression du groupe Docker ----------------------------------"
sudo groupdel docker || echo "Le groupe Docker n'existe pas."

echo "---------------------------------- Nettoyage des règles de pare-feu ----------------------------------"
sudo iptables -t nat -F || echo "Aucune règle Docker trouvée."

echo "---------------------------------- Redémarrage du système (optionnel) ----------------------------------"
read -p "Voulez-vous redémarrer le système maintenant ? (y/N) " response
if [[ "$response" =~ ^[Yy]$ ]]; then
    sudo reboot
else
    echo "Redémarrage annulé."
fi

echo "Désinstallation complète terminée !"
