#!/bin/bash
set -e

TOMCAT_VERSION="10.1.18"
TOMCAT_USER="tomcat"
TOMCAT_HOME="/opt/tomcat"
JAVA_VERSION="17"

echo "=== [1/5] Installation Java ${JAVA_VERSION} ==="
sudo apt-get update -q
sudo apt-get install -y openjdk-${JAVA_VERSION}-jdk

java -version

echo "=== [2/5] Création utilisateur Tomcat ==="
if ! id "${TOMCAT_USER}" &>/dev/null; then
    sudo useradd -m -U -d ${TOMCAT_HOME} -s /bin/false ${TOMCAT_USER}
fi

echo "=== [3/5] Téléchargement Tomcat ${TOMCAT_VERSION} ==="
cd /tmp
wget -q "https://downloads.apache.org/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
sudo mkdir -p ${TOMCAT_HOME}
sudo tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C ${TOMCAT_HOME} --strip-components=1
sudo chown -R ${TOMCAT_USER}:${TOMCAT_USER} ${TOMCAT_HOME}
sudo chmod +x ${TOMCAT_HOME}/bin/*.sh
rm -f /tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz

echo "=== [4/5] Création service systemd ==="
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat 10
After=network.target

[Service]
Type=forking
User=${TOMCAT_USER}
Group=${TOMCAT_USER}
Environment="JAVA_HOME=${JAVA_HOME}"
Environment="CATALINA_HOME=${TOMCAT_HOME}"
Environment="CATALINA_PID=${TOMCAT_HOME}/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
ExecStart=${TOMCAT_HOME}/bin/startup.sh
ExecStop=${TOMCAT_HOME}/bin/shutdown.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "=== [5/5] Démarrage Tomcat ==="
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

echo ""
echo "✅ Tomcat installé et démarré"
echo "   Home     : ${TOMCAT_HOME}"
echo "   Port     : 8080"
echo "   Webapps  : ${TOMCAT_HOME}/webapps"
echo ""
echo "Commandes utiles :"
echo "  sudo systemctl status tomcat"
echo "  sudo systemctl restart tomcat"
echo "  sudo tail -f ${TOMCAT_HOME}/logs/catalina.out"
