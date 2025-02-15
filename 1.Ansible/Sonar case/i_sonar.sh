#!/bin/bash

sudo apt update && sudo apt upgrade -y


echo "----------------------------------special EC2--------------------------------------------------"

#sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

echo "----------------------------------installation docker------------------------------------------"

sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin


sudo usermod -aG docker $USER
newgrp docker

echo "---------------------------------fin installation docker----------------------------------------"

echo "---------------------------------lancement sonarqube--------------------------------------------"

# Créer un réseau Docker dédié pour SonarQube
docker network create sonarnet

# Lancer un conteneur PostgreSQL pour SonarQube
docker run -d --name postgres-sonar \
  --network sonarnet \
  -e POSTGRES_USER=sonar \
  -e POSTGRES_PASSWORD=sonar \
  -e POSTGRES_DB=sonarqube \
  -v sonarqube_db:/var/lib/postgresql/data \
  postgres:13

# Lancer le conteneur SonarQube
docker run -d --name sonarqube \
  --network sonarnet \
  -p 9000:9000 \
  -e SONAR_JDBC_URL=jdbc:postgresql://postgres-sonar:5432/sonarqube \
  -e SONAR_JDBC_USERNAME=sonar \
  -e SONAR_JDBC_PASSWORD=sonar \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  sonarqube:lts-community

docker ps

