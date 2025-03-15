### 1. **Exercice Nginx : Ajouter ou modifier la directive `server_name` dans `nginx.conf`**

**Objectif :**  
Ajouter ou modifier la ligne `server_name example.com;` dans le fichier de configuration `nginx.conf`.

**Exemple de fichier `nginx.conf` avant modification :**

```nginx
http {
    include       mime.types;
    default_type  application/octet-stream;

    # server_name directive is missing
    server {
        listen 80;
        root /usr/share/nginx/html;
    }
}
```
---

### 2. **Exercice Tomcat : Ajouter un utilisateur dans `tomcat-users.xml` avant un rôle spécifique**

**Objectif :**  
Ajouter un utilisateur `admin` avec le rôle `manager-gui` dans le fichier `tomcat-users.xml`, juste avant une ligne contenant un rôle spécifique.

**Exemple de fichier `tomcat-users.xml` avant modification :**

```xml
<tomcat-users>
    <role rolename="admin-gui"/>
    <role rolename="manager-gui"/>
    <!-- Commented lines below -->
    <!-- <user username="admin" password="adminpass" roles="admin-gui,manager-gui"/> -->
</tomcat-users>
```
---

### 3. **Exercice HTTPD : Remplacer une directive commentée par une active**

**Objectif :**  
Remplacer la ligne commentée `#ServerName localhost` par `ServerName localhost` dans le fichier `httpd.conf`.

**Exemple de fichier `httpd.conf` avant modification :**

```apache
#ServerName localhost
Listen 80
LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
```
---

### 4. **Exercice Nginx : Insérer une ligne après une ligne cible**

**Objectif :**  
Ajouter une directive `server_tokens off;` juste après la ligne `listen 80;` dans le fichier `nginx.conf`.

**Exemple de fichier `nginx.conf` avant modification :**

```nginx
http {
    include       mime.types;
    default_type  application/octet-stream;

    server {
        listen 80;
        root /usr/share/nginx/html;
    }
}
```
---

### 5. **Exercice HTTPD : Insérer une ligne avant une ligne cible**

**Objectif :**  
Ajouter la ligne `ServerAdmin webmaster@localhost` avant la ligne `Listen 80` dans le fichier `httpd.conf`.

**Exemple de fichier `httpd.conf` avant modification :**

```apache
Listen 80
LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
```
---

### 6. **Exercice Tomcat : Supprimer une ligne spécifique dans `tomcat-users.xml`**

**Objectif :**  
Supprimer une ligne spécifique contenant un utilisateur existant.

**Exemple de fichier `tomcat-users.xml` avant modification :**

```xml
<tomcat-users>
    <role rolename="admin-gui"/>
    <user username="admin" password="adminpass" roles="admin-gui,manager-gui"/>
</tomcat-users>
```
---
