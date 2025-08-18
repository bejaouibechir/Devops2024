# Cas d'utilisation du dossier Tomcat

Voici la procédure complète pour installer et configurer **Apache Tomcat 10.1.28** sur **Ubuntu 22.04**, incluant les actions de post-installation pour accéder à la **Manager App** et au **Host Manager** :

### 1. Mise à jour du système
```bash
sudo apt update && sudo apt upgrade
```

### 2. Installer Java
```bash
sudo apt install default-jdk
```

### 3. Télécharger et installer Tomcat 10.1.28
```bash
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.28/bin/apache-tomcat-10.1.28.tar.gz
tar xzvf apache-tomcat-10.1.28.tar.gz
sudo mv apache-tomcat-10.1.28 /opt/tomcat
```

### 4. Configurer les permissions
```bash
sudo chmod +x /opt/tomcat/bin/*.sh
```

### 5. Démarrer Tomcat
```bash
/opt/tomcat/bin/startup.sh
```

Tomcat sera disponible sur `http://localhost:8080`.

### 6. Configurer l'accès à Manager App et Host Manager
#### Modifier `tomcat-users.xml`
```bash
sudo nano /opt/tomcat/conf/tomcat-users.xml
```
Ajouter les rôles et utilisateurs suivants :
```xml
<role rolename="manager-gui"/>
<role rolename="admin-gui"/>
<user username="admin" password="password" roles="manager-gui,admin-gui"/>
```

#### Modifier `context.xml`
Supprimer ou commenter la ligne `<Valve ...>` dans :
```bash
sudo nano /opt/tomcat/webapps/manager/META-INF/context.xml
sudo nano /opt/tomcat/webapps/host-manager/META-INF/context.xml
```

### 7. Redémarrer Tomcat
```bash
/opt/tomcat/bin/shutdown.sh
/opt/tomcat/bin/startup.sh
```

Vous pouvez maintenant accéder à la **Manager App** et au **Host Manager** avec les identifiants que vous avez configurés.
