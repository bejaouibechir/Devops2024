# Exercice sur les modules

Voici une suite d'exercices Ansible, classée par complexité croissante, illustrant les modules natifs et leur utilité dans des contextes réalistes.

---

### 1. **Exercice : Command vs Shell**
**Objectif** : Comprendre la différence entre `command` et `shell`.  
**Cas pratique** : Lister les fichiers d'un répertoire en vérifiant leur présence.  

**Étape 1** : Utilisez `command` pour lister le contenu de `/tmp` et renvoyez une erreur si le répertoire n'existe pas.  
**Étape 2** : Utilisez `shell` pour exécuter une commande plus complexe : vérifier si un fichier spécifique existe dans `/tmp`.

**Playbook** :
```yaml
- name: Command vs Shell Example
  hosts: localhost
  tasks:
    - name: List files using command
      command: ls /tmp

    - name: Check if a specific file exists using shell
      shell: "[ -f /tmp/special_file.txt ] && echo 'Exists' || echo 'Not found'"
      register: shell_output
    - debug:
        msg: "Result: {{ shell_output.stdout }}"
```

---

### 2. **Exercice : Module Service**
**Objectif** : Gérer un service (Nginx).  
**Cas pratique** : Installer Nginx, démarrer le service, puis le redémarrer si une configuration change.

**Playbook** :
```yaml
- name: Manage Nginx service
  hosts: localhost
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
      become: true

    - name: Ensure Nginx is running
      service:
        name: nginx
        state: started
      become: true

    - name: Restart Nginx if config changes
      copy:
        src: ./nginx.conf
        dest: /etc/nginx/nginx.conf
        backup: yes
      notify: Restart Nginx

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
      become: true
```

---

### 3. **Exercice : File vs Copy vs Template**
**Objectif** : Différencier les modules `file`, `copy`, et `template`.  
**Cas pratique** :  
- Créer un répertoire avec `file`.  
- Copier un fichier statique avec `copy`.  
- Créer un fichier de configuration dynamique avec `template`.

**Playbook** :
```yaml
- name: File, Copy, and Template Example
  hosts: localhost
  tasks:
    - name: Create a directory
      file:
        path: /tmp/test_dir
        state: directory

    - name: Copy a static file
      copy:
        src: ./static_file.txt
        dest: /tmp/test_dir/static_file.txt

    - name: Deploy dynamic config with template
      template:
        src: ./config.j2
        dest: /tmp/test_dir/config.conf
      vars:
        app_name: "MyApp"
        environment: "production"
```

---

### 4. **Exercice : Module Lineinfile**
**Objectif** : Ajouter ou modifier une ligne dans un fichier de configuration (Nginx).  
**Cas pratique** : Assurez-vous que le fichier `/etc/nginx/nginx.conf` contient une directive personnalisée.

**Playbook** :
```yaml
- name: Modify Nginx configuration
  hosts: localhost
  tasks:
    - name: Add a custom log directive
      lineinfile:
        path: /etc/nginx/nginx.conf
        regexp: '^error_log'
        line: "error_log /var/log/nginx/custom_error.log;"
        state: present
      become: true
```

---

### 5. **Exercice : Module Get_url**
**Objectif** : Télécharger un fichier à partir d'une URL.  
**Cas pratique** : Télécharger une archive et vérifier qu'elle est disponible.

**Playbook** :
```yaml
- name: Download file with get_url
  hosts: localhost
  tasks:
    - name: Download a file
      get_url:
        url: https://example.com/sample.tar.gz
        dest: /tmp/sample.tar.gz

    - name: Verify the file exists
      stat:
        path: /tmp/sample.tar.gz
      register: file_stat

    - debug:
        msg: "Downloaded file size: {{ file_stat.stat.size }} bytes"
```

---

### 6. **Exercice : Modules d’archivage**
**Objectif** : Compresser et décompresser des fichiers/dossiers.  
**Cas pratique** :  
1. Archiver le contenu d’un répertoire.  
2. Extraire l’archive dans un autre répertoire.

**Playbook** :
```yaml
- name: Archive and Extract Example
  hosts: localhost
  tasks:
    - name: Create an archive
      archive:
        path: /tmp/test_dir
        dest: /tmp/test_archive.tar.gz

    - name: Extract the archive
      unarchive:
        src: /tmp/test_archive.tar.gz
        dest: /tmp/extracted_dir
        remote_src: yes
```

---

### 7. **Exercice : Modules Avancés (Bonus)**
**Objectif** : Utiliser un module plus complexe comme `debug`, `find`, ou `set_fact`.  
**Cas pratique** : Trouver tous les fichiers dans un répertoire, filtrer les fichiers `.txt`, et afficher leur liste.

**Playbook** :
```yaml
- name: Advanced Example with find and set_fact
  hosts: localhost
  tasks:
    - name: Find all files in directory
      find:
        paths: /tmp/test_dir
        patterns: "*.txt"
      register: txt_files

    - name: Display found files
      debug:
        msg: "Found files: {{ txt_files.files | map(attribute='path') | list }}"
```

