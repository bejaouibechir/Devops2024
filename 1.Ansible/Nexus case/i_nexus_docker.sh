#!/bin/bash

set -e  # Arrêter le script en cas d'erreur

echo "---------------------------------- Mise à jour du système ----------------------------------"
sudo apt update && sudo apt upgrade -y

echo "---------------------------------- Vérification de Docker ----------------------------------"
if ! command -v docker &> /dev/null
then
    echo "Docker non installé. Installation en cours..."

    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Ajouter l'utilisateur au groupe Docker
    sudo usermod -aG docker $USER
    newgrp docker

    echo "Docker installé avec succès."
else
    echo "Docker est déjà installé. Aucune action nécessaire."
fi

echo "---------------------------------- Vérification du port 8081 ----------------------------------"
NEXUS_PORT=8081

# Vérifier si un conteneur utilise déjà le port 8081
while sudo docker ps --format '{{ .Ports }}' | grep -Eo '[0-9]+(?->8081)' &> /dev/null; do
    ((NEXUS_PORT++))
done

echo "Le port disponible pour Nexus est : $NEXUS_PORT"

echo "---------------------------------- Déploiement de Nexus ----------------------------------"
sudo docker run -d --name nexus \
    -p $NEXUS_PORT:8081 \
    -v nexus-data:/nexus-data \
    --restart always \
    sonatype/nexus3

echo "Nexus est déployé sur le port $NEXUS_PORT."

sudo docker ps
