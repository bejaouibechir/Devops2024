#!/bin/bash

# Définition des variables
TOMCAT_USER="tomcat"
TOMCAT_DIR="/opt/tomcat"
TOMCAT_SERVICE="/etc/systemd/system/tomcat.service"

echo "🔹 Arrêt du service Tomcat..."
sudo systemctl stop tomcat 2>/dev/null
sudo systemctl disable tomcat 2>/dev/null

echo "🔹 Suppression du fichier de service systemd..."
sudo rm -f $TOMCAT_SERVICE

echo "🔹 Rechargement du démon systemd..."
sudo systemctl daemon-reload

echo "🔹 Suppression du répertoire Tomcat..."
sudo rm -rf $TOMCAT_DIR

echo "🔹 Suppression de l'utilisateur Tomcat..."
sudo userdel -r $TOMCAT_USER 2>/dev/null

echo "🔹 Désinstallation de Java..."
sudo apt remove --purge -y default-jdk
sudo apt autoremove -y
sudo apt autoclean -y

echo " Tomcat et ses dépendances ont été complètement supprimés."
