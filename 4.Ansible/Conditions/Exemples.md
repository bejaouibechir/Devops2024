# Exercices sur les conditions

### **Exercices sur `when`**

#### 1. Vérifier et installer un paquet uniquement si absent
**Objectif** : Installer `curl` si non installé.
```yaml
- name: Install curl if not present
  hosts: localhost
  tasks:
    - name: Check if curl is installed
      command: which curl
      register: curl_check
      ignore_errors: yes

    - name: Install curl
      apt:
        name: curl
        state: present
      when: curl_check.rc != 0
      become: true
```

---

#### 2. Redémarrer un service uniquement si un fichier est modifié
**Objectif** : Redémarrer Nginx uniquement après modification de son fichier de configuration.
```yaml
- name: Conditional restart of Nginx
  hosts: localhost
  tasks:
    - name: Update Nginx configuration
      copy:
        src: nginx.conf
        dest: /etc/nginx/nginx.conf
        backup: yes
        register: nginx_config

    - name: Restart Nginx if configuration changes
      service:
        name: nginx
        state: restarted
      when: nginx_config.changed
      become: true
```

---

#### 3. Vérifier un système d’exploitation avant d’exécuter une tâche
**Objectif** : Exécuter une tâche uniquement sur Ubuntu.
```yaml
- name: OS-specific task
  hosts: localhost
  tasks:
    - name: Run a task on Ubuntu
      debug:
        msg: "This is Ubuntu"
      when: ansible_facts['os_family'] == "Debian"
```

---

#### 4. Condition basée sur une variable
**Objectif** : Installer un paquet selon l'environnement.
```yaml
- name: Install based on environment
  hosts: localhost
  vars:
    environment: production
  tasks:
    - name: Install monitoring tools in production
      apt:
        name: htop
        state: present
      when: environment == "production"
      become: true
```

---

#### 5. Condition sur une boucle
**Objectif** : Créer des répertoires uniquement pour certains utilisateurs.
```yaml
- name: Create directories for specific users
  hosts: localhost
  tasks:
    - name: Create home directories
      file:
        path: "/home/{{ item }}"
        state: directory
      with_items:
        - alice
        - bob
        - charlie
      when: item != "charlie"
```

---

### **Exercices sur `register`**

#### 6. Vérifier un service avant de le démarrer
**Objectif** : Démarrer Nginx uniquement s'il est arrêté.
```yaml
- name: Start Nginx conditionally
  hosts: localhost
  tasks:
    - name: Check Nginx status
      service:
        name: nginx
        state: started
      register: nginx_status

    - name: Start Nginx
      service:
        name: nginx
        state: started
      when: nginx_status.state != "started"
      become: true
```

---

#### 7. Récupérer des fichiers et les afficher
**Objectif** : Lister les fichiers d’un répertoire et afficher leur contenu.
```yaml
- name: List and debug files
  hosts: localhost
  tasks:
    - name: Find all .txt files
      find:
        paths: /tmp
        patterns: "*.txt"
      register: txt_files

    - name: Display file paths
      debug:
        msg: "Found files: {{ txt_files.files | map(attribute='path') | list }}"
```

---

#### 8. Vérifier un port avant de le configurer
**Objectif** : Configurer un pare-feu uniquement si un port est ouvert.
```yaml
- name: Check and configure port
  hosts: localhost
  tasks:
    - name: Check if port 80 is open
      command: "netstat -tuln | grep :80"
      register: port_check
      ignore_errors: yes

    - name: Allow port 80 in firewall
      firewalld:
        port: 80/tcp
        permanent: true
        state: enabled
      when: port_check.rc == 0
      become: true
```

---

#### 9. Déploiement conditionnel après vérification
**Objectif** : Déployer un fichier si un service est actif.
```yaml
- name: Deploy file if service is active
  hosts: localhost
  tasks:
    - name: Check if Nginx is running
      service:
        name: nginx
        state: started
      register: nginx_status

    - name: Deploy configuration file
      copy:
        src: new_config.conf
        dest: /etc/nginx/nginx.conf
      when: nginx_status.state == "started"
      become: true
```

---

#### 10. Création conditionnelle d’utilisateurs
**Objectif** : Créer un utilisateur uniquement si un groupe existe.
```yaml
- name: Add user based on group existence
  hosts: localhost
  tasks:
    - name: Check if group exists
      command: "getent group deploy_group"
      register: group_check
      ignore_errors: yes

    - name: Create deploy user
      user:
        name: deploy_user
        groups: deploy_group
        state: present
      when: group_check.rc == 0
      become: true
```

---

### **Exercices sur `ignore_errors`**

#### 11. Ignorer une erreur et continuer
**Objectif** : Créer un répertoire, même si un autre échoue.
```yaml
- name: Ignore errors and continue
  hosts: localhost
  tasks:
    - name: Attempt to remove a non-existent file
      file:
        path: /tmp/non_existent_file
        state: absent
      ignore_errors: yes

    - name: Create a directory
      file:
        path: /tmp/test_dir
        state: directory
```

---

#### 12. Enregistrer les erreurs ignorées
**Objectif** : Enregistrer les erreurs pour analyse.
```yaml
- name: Register ignored errors
  hosts: localhost
  tasks:
    - name: Attempt to list a non-existent directory
      command: ls /non_existent_directory
      register: command_result
      ignore_errors: yes

    - name: Debug command output
      debug:
        msg: "Command failed with: {{ command_result.stderr }}"
```

---

#### 13. Tester plusieurs actions malgré des erreurs
**Objectif** : Tester plusieurs commandes sans interrompre le playbook.
```yaml
- name: Run multiple commands with error handling
  hosts: localhost
  tasks:
    - name: Check disk usage
      shell: df -h /invalid_mount
      ignore_errors: yes

    - name: List files
      command: ls /tmp
```

---

#### 14. Déploiement partiel malgré une erreur
**Objectif** : Déployer plusieurs fichiers même si un échoue.
```yaml
- name: Partial deployment with errors
  hosts: localhost
  tasks:
    - name: Deploy files
      copy:
        src: "{{ item.src }}"
        dest: "{{ item.dest }}"
      with_items:
        - { src: valid_file.txt, dest: /tmp/valid_file.txt }
        - { src: missing_file.txt, dest: /tmp/missing_file.txt }
      ignore_errors: yes
```

---

#### 15. Gérer les erreurs dans une boucle
**Objectif** : Installer des paquets tout en gérant les erreurs.
```yaml
- name: Install packages with error handling
  hosts: localhost
  tasks:
    - name: Attempt to install packages
      apt:
        name: "{{ item }}"
        state: present
      with_items:
        - git
        - non_existent_package
        - curl
      ignore_errors: yes
      become: true
```
