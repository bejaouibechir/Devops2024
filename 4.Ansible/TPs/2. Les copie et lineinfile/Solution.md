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

**Solution :**

```yaml
---
- name: Ajouter ou modifier server_name dans nginx.conf
  hosts: localhost
  become: yes
  tasks:
    - name: Ajouter ou remplacer la directive server_name
      ansible.builtin.lineinfile:
        path: /etc/nginx/nginx.conf
        regexp: '^server_name'
        line: 'server_name example.com;'
        create: yes
```

**Explication :**
- Si la directive `server_name` existe, elle sera remplacée par `server_name example.com;`.
- Si la directive n'existe pas, elle sera ajoutée à la fin du fichier.

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

**Solution :**

```yaml
---
- name: Ajouter un utilisateur admin avant le rôle manager-gui
  hosts: localhost
  become: yes
  tasks:
    - name: Ajouter l'utilisateur admin avant manager-gui
      ansible.builtin.lineinfile:
        path: /opt/tomcat/conf/tomcat-users.xml
        regexp: '^<role rolename="manager-gui"/>'
        line: '<user username="admin" password="adminpass" roles="manager-gui"/>'
        insertafter: '^<role rolename="manager-gui"/>'
        create: yes
```

**Explication :**
- La ligne de l'utilisateur est insérée juste après la ligne contenant `<role rolename="manager-gui"/>`.
- Le paramètre `insertafter` assure l'insertion avant le rôle `manager-gui`.

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

**Solution :**

```yaml
---
- name: Remplacer ServerName localhost dans httpd.conf
  hosts: localhost
  become: yes
  tasks:
    - name: Remplacer la ligne commentée par ServerName localhost
      ansible.builtin.lineinfile:
        path: /etc/httpd/conf/httpd.conf
        regexp: '^#ServerName'
        line: 'ServerName localhost'
        create: yes
```

**Explication :**
- La directive `ServerName localhost` remplace la ligne commentée `#ServerName localhost` en utilisant le paramètre `regexp` pour rechercher la ligne commentée.
- Si la ligne est commentée, elle sera décommentée et remplacée par `ServerName localhost`.

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

**Solution :**

```yaml
---
- name: Ajouter server_tokens off après listen 80
  hosts: localhost
  become: yes
  tasks:
    - name: Ajouter la directive server_tokens off après listen 80
      ansible.builtin.lineinfile:
        path: /etc/nginx/nginx.conf
        regexp: '^listen 80;'
        line: 'server_tokens off;'
        insertafter: '^listen 80;'
        create: yes
```

**Explication :**
- La directive `server_tokens off;` est insérée juste après la ligne `listen 80;`.
- Le paramètre `insertafter` permet de cibler cette ligne précise et insérer la nouvelle directive juste après.

---

### 5. **Exercice HTTPD : Insérer une ligne avant une ligne cible**

**Objectif :**  
Ajouter la ligne `ServerAdmin webmaster@localhost` avant la ligne `Listen 80` dans le fichier `httpd.conf`.

**Exemple de fichier `httpd.conf` avant modification :**

```apache
Listen 80
LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
```

**Solution :**

```yaml
---
- name: Ajouter ServerAdmin avant Listen 80 dans httpd.conf
  hosts: localhost
  become: yes
  tasks:
    - name: Ajouter ServerAdmin avant Listen 80
      ansible.builtin.lineinfile:
        path: /etc/httpd/conf/httpd.conf
        regexp: '^Listen 80'
        line: 'ServerAdmin webmaster@localhost'
        insertbefore: '^Listen 80'
        create: yes
```

**Explication :**
- La ligne `ServerAdmin webmaster@localhost` est insérée juste avant la ligne `Listen 80`.
- Le paramètre `insertbefore` permet de définir l'endroit précis pour l'insertion.

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

**Solution :**

```yaml
---
- name: Supprimer un utilisateur dans tomcat-users.xml
  hosts: localhost
  become: yes
  tasks:
    - name: Supprimer l'utilisateur admin
      ansible.builtin.lineinfile:
        path: /opt/tomcat/conf/tomcat-users.xml
        regexp: '^<user username="admin"'
        state: absent
```

**Explication :**
- La ligne contenant `<user username="admin" ... />` est supprimée en utilisant `state: absent`.
- Le paramètre `regexp` cible la ligne à supprimer.

---
