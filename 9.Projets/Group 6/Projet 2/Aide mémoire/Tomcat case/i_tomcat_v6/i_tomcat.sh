#!/bin/bash

# Définition des variables
TOMCAT_VERSION="10.1.35"
TOMCAT_USER="tomcat"
TOMCAT_GROUP="tomcat"
INSTALL_MARKER_FILE="/opt/tomcat/.installation_complete"
TOMCAT_DOWNLOAD_URL="https://dlcdn.apache.org/tomcat/tomcat-10/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz"
JAVA_PACKAGE="default-jdk"

# Vérification si Tomcat est déjà installé
if [ -f "$INSTALL_MARKER_FILE" ]; then
    echo "Tomcat est déjà installé. Fin du script."
    exit 0
fi

# Mise à jour des paquets et installation de Java
echo "Mise à jour des paquets..."
sudo apt update -y
echo "Installation de Java..."
sudo apt install -y $JAVA_PACKAGE

# Création de l'utilisateur Tomcat
echo "Création de l'utilisateur Tomcat..."
sudo useradd -m -d /opt/tomcat -s /bin/false $TOMCAT_USER

# Téléchargement et extraction de Tomcat
echo "Téléchargement de Tomcat..."
wget $TOMCAT_DOWNLOAD_URL -O /tmp/apache-tomcat-$TOMCAT_VERSION.tar.gz
echo "Extraction de Tomcat..."
sudo mkdir -p /opt/tomcat
sudo tar -xzf /tmp/apache-tomcat-$TOMCAT_VERSION.tar.gz -C /opt/tomcat --strip-components=1

# Attribution des permissions
echo "Configuration des permissions..."
sudo chown -R $TOMCAT_USER:$TOMCAT_GROUP /opt/tomcat
sudo chmod +x /opt/tomcat/bin/*.sh

# Copie des fichiers de configuration
echo "Copie des fichiers de configuration..."
sudo cp ./tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml
sudo cp ./manager-context.xml /opt/tomcat/webapps/manager/META-INF/context.xml
sudo cp ./hmanager-context.xml /opt/tomcat/webapps/host-manager/META-INF/context.xml
sudo chown $TOMCAT_USER:$TOMCAT_GROUP /opt/tomcat/conf/tomcat-users.xml
sudo chown $TOMCAT_USER:$TOMCAT_GROUP /opt/tomcat/webapps/manager/META-INF/context.xml
sudo chown $TOMCAT_USER:$TOMCAT_GROUP /opt/tomcat/webapps/host-manager/META-INF/context.xml

# Création du fichier service systemd
echo "Création du service systemd..."
cat <<EOF | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat Application Server
After=network.target

[Service]
Type=forking
User=$TOMCAT_USER
Group=$TOMCAT_GROUP
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Rechargement systemd, activation et démarrage du service
echo "Configuration du service Tomcat..."
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

# Création du fichier marqueur d'installation
echo "Création du fichier de confirmation d'installation..."
sudo touch "$INSTALL_MARKER_FILE"
sudo chown $TOMCAT_USER:$TOMCAT_GROUP "$INSTALL_MARKER_FILE"

echo "Installation de Tomcat terminée avec succès."
