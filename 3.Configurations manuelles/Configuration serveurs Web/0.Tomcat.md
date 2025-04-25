## **Tutoriel : Installation, Configuration et Démonstrations pratiques avec Tomcat**

### **1. Installation de Tomcat**
#### **1.1 Télécharger et Installer**
1. **Téléchargez Tomcat** :
   ```bash
   wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.8/bin/apache-tomcat-10.1.8.tar.gz -P /tmp
   ```

2. **Décompressez l’archive** :
   ```bash
   sudo mkdir -p /opt/tomcat
   sudo tar -xzf /tmp/apache-tomcat-10.1.8.tar.gz -C /opt/tomcat --strip-components=1
   ```

3. **Configurer les permissions** :
   ```bash
   sudo chmod -R 755 /opt/tomcat
   sudo chown -R $USER:$USER /opt/tomcat
   ```

---

### **2. Démarrage et Test de Tomcat**

#### **2.1 Démarrer Tomcat**
1. Exécutez le script de démarrage inclus dans Tomcat :
   ```bash
   /opt/tomcat/bin/startup.sh
   ```

2. Vérifiez si Tomcat est démarré :
   ```bash
   curl -I http://localhost:8080
   ```

3. **Résultat attendu** : Une réponse HTTP 200 confirme que Tomcat fonctionne.

---

### **3. Démonstrations pratiques**

---

#### **3.1 Changer le port d’écoute**
1. **Modifier le fichier `server.xml`** :
   ```bash
   nano /opt/tomcat/conf/server.xml
   ```

2. **Localisez cette section** :
   ```xml
   <Connector port="8080" protocol="HTTP/1.1"
              connectionTimeout="20000"
              redirectPort="8443" />
   ```

3. **Remplacez le port `8080` par `9090`** :
   ```xml
   <Connector port="9090" protocol="HTTP/1.1"
              connectionTimeout="20000"
              redirectPort="8443" />
   ```

4. **Redémarrez Tomcat** :
   ```bash
   /opt/tomcat/bin/shutdown.sh
   /opt/tomcat/bin/startup.sh
   ```

5. **Tester le nouveau port** :
   - Accédez à :
     ```
     http://localhost:9090
     ```
   - Vous devriez voir la page d’accueil de Tomcat.

---

#### **3.2 Lire les journaux pour vérifier les changements**
1. **Afficher les dernières lignes des journaux de Tomcat** :
   ```bash
   tail -n 10 /opt/tomcat/logs/catalina.out
   ```

2. **Rechercher une erreur spécifique dans les journaux** :
   Par exemple, pour rechercher des erreurs liées aux ports :
   ```bash
   grep "port" /opt/tomcat/logs/catalina.out
   ```

3. **Afficher les journaux en temps réel** :
   Utilisez la commande `tail` pour surveiller les journaux en direct :
   ```bash
   tail -f /opt/tomcat/logs/catalina.out
   ```

---

#### **3.3 Gérer Tomcat comme un service systemd**
1. **Créer un fichier de service** :
   ```bash
   sudo nano /etc/systemd/system/tomcat.service
   ```

2. **Ajoutez cette configuration** :
   ```ini
   [Unit]
   Description=Apache Tomcat Web Application Container
   After=network.target

   [Service]
   Type=forking
   ExecStart=/opt/tomcat/bin/startup.sh
   ExecStop=/opt/tomcat/bin/shutdown.sh
   User=ubuntu
   Group=ubuntu
   Restart=on-failure

   [Install]
   WantedBy=multi-user.target
   ```

3. **Rechargez systemd et démarrez Tomcat comme un service** :
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start tomcat
   sudo systemctl enable tomcat
   ```

4. **Tester les commandes systemd** :
   - Vérifiez l’état :
     ```bash
     sudo systemctl status tomcat
     ```
   - Redémarrez :
     ```bash
     sudo systemctl restart tomcat
     ```
   - Arrêtez le service :
     ```bash
     sudo systemctl stop tomcat
     ```

---

#### **3.4 Déployer une application dans Tomcat**
1. **Créer une application WAR minimale** :
   Créez un fichier `sample.war` avec une simple page JSP.

2. **Déployer l’application** :
   Copiez l’application dans le répertoire `webapps` de Tomcat :
   ```bash
   cp sample.war /opt/tomcat/webapps/
   ```

3. **Tester l’application** :
   Accédez à l’URL suivante :
   ```
   http://localhost:9090/sample
   ```

---

#### **3.5 Explorer les fichiers importants**
1. **Fichiers de configuration principaux** :
   - **`/opt/tomcat/conf/server.xml`** : Configuration du serveur.
   - **`/opt/tomcat/conf/web.xml`** : Paramètres par défaut des applications.

2. **Répertoire des journaux** :
   - **`/opt/tomcat/logs/`** : Contient les journaux d'exécution, les erreurs, et les accès.

3. **Répertoire des applications déployées** :
   - **`/opt/tomcat/webapps/`** : Contient les applications déployées (ex. : ROOT, manager).

---

#### **3.6 Activer la console d’administration**
1. **Modifier le fichier `tomcat-users.xml`** :
   ```bash
   nano /opt/tomcat/conf/tomcat-users.xml
   ```

2. **Ajoutez un utilisateur admin** :
   ```xml
   <role rolename="manager-gui"/>
   <role rolename="admin-gui"/>
   <user username="admin" password="password" roles="manager-gui,admin-gui"/>
   ```

3. **Redémarrez Tomcat** :
   ```bash
   sudo systemctl restart tomcat
   ```

4. **Accédez à la console** :
   ```
   http://localhost:9090/manager/html
   ```

---

### **4. Dépannage courant**

#### **Problème : Port déjà utilisé**
1. **Vérifiez les ports utilisés** :
   ```bash
   sudo netstat -tuln | grep 8080
   ```

2. **Trouvez le processus utilisant le port** :
   ```bash
   sudo lsof -i :8080
   ```

3. **Tuez le processus** :
   ```bash
   sudo kill -9 <PID>
   ```

---

### **5. Résumé des manipulations pratiques**
1. **Changer le port d’écoute** :
   - Fichier : `/opt/tomcat/conf/server.xml`.
   - Testez le nouveau port avec :
     ```
     curl -I http://localhost:<nouveau_port>
     ```

2. **Afficher et surveiller les journaux** :
   ```bash
   tail -f /opt/tomcat/logs/catalina.out
   ```

3. **Déployer une application WAR** :
   - Copiez le fichier dans `/opt/tomcat/webapps`.

4. **Gérer le service Tomcat** :
   ```bash
   sudo systemctl start|stop|restart tomcat
   ```
