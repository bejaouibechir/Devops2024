# Préparation du terrain 

Voici la première partie pour la configuration de **GitLab** et **Jenkins** pour exécuter des commandes Ansible avant de passer aux démos :
## Préparation de Gitlab
si le GitLab Runner n’a pas Ansible installé, cela ne suffira pas pour exécuter les commandes Ansible directement. Voici les options pour s’assurer qu’Ansible est disponible :

1. **Utiliser une image Docker avec Ansible intégré** :
   - Spécifiez dans votre `.gitlab-ci.yml` une image Docker qui contient Ansible, comme `ansible/ansible`.
   - Exemple :
     ```yaml
     image: ansible/ansible:latest

     stages:
       - ansible_run

     ansible_playbook:
       stage: ansible_run
       script:
         - ansible --version  # Vérification qu'Ansible est bien présent
         - ansible-playbook -i inventory playbook.yml
     ```

2. **Installer Ansible dans le Runner s’il est basé sur Shell** :
   - Si vous utilisez un Runner Shell, installez Ansible directement sur le serveur du Runner :
     ```bash
     sudo apt update
     sudo apt install -y ansible
     ```
   - Ensuite, ajoutez les scripts Ansible dans `.gitlab-ci.yml` sans spécifier d’image Docker.

3. **Installer Ansible à la volée dans le script** (si Docker et Shell sont indisponibles) :
   - Ajoutez une étape d’installation d’Ansible dans `.gitlab-ci.yml`, bien que cette approche soit moins efficace.
     ```yaml
     stages:
       - ansible_run

     ansible_playbook:
       stage: ansible_run
       script:
         - apt update && apt install -y ansible
         - ansible-playbook -i inventory playbook.yml
     ```

Ces options garantissent que le Runner a accès à Ansible pour exécuter les commandes.


### Configuration de GitLab pour exécuter Ansible
1. **Créer un projet GitLab** :
   - Créez un dépôt GitLab où seront stockés les fichiers Ansible.

2. **Configurer le GitLab Runner** :
   - Installez un **GitLab Runner** compatible avec Docker ou Shell pour exécuter les commandes Ansible.
   - Dans `.gitlab-ci.yml`, définissez les étapes avec `image: ansible/ansible:latest` pour une image Docker prête pour Ansible.

3. **Créer le fichier `.gitlab-ci.yml`** :
   - Exemple de fichier `.gitlab-ci.yml` pour exécuter un playbook Ansible :
     ```yaml
     stages:
       - ansible_run

     ansible_playbook:
       stage: ansible_run
       script:
         - ansible-playbook -i inventory playbook.yml
       only:
         - main
     ```
4. **Ajouter des Clés SSH** :
   - Ajoutez une clé SSH privée comme variable GitLab (Settings > CI/CD > Variables) pour autoriser la connexion Ansible vers les serveurs cibles.

5. **Inventaire dynamique** :
   - Ajoutez un inventaire dynamique pour plus de flexibilité (`inventory` dans `.gitlab-ci.yml`).

### Configuration de Jenkins pour Ansible
1. **Installer les Plugins Jenkins** :
   - Plugins nécessaires : **Ansible**, **SSH Agent**, **Git**.

2. **Configurer le chemin d’Ansible** :
   - Allez dans Jenkins > Manage Jenkins > Configure System.
   - Ajoutez Ansible sous **Ansible installations** et indiquez le chemin d'installation.

3. **Configurer un job Jenkins pour exécuter Ansible** :
   - Dans un nouveau job de type "Freestyle" ou "Pipeline", ajoutez une étape pour exécuter Ansible.
   - Exemple de configuration dans un pipeline Jenkinsfile :
     ```groovy
     pipeline {
         agent any
         stages {
             stage('Ansible Execution') {
                 steps {
                     ansiblePlaybook playbook: 'playbook.yml', inventory: 'inventory'
                 }
             }
         }
     }
     ```

4. **Ajouter des Clés SSH dans Jenkins** :
   - Configurez une clé SSH pour que Jenkins accède aux serveurs Ansible cibles (Manage Jenkins > Manage Credentials).

Voici les premières démos de la série Ansible, avec une progression en complexité pour comprendre progressivement l’utilisation des commandes ad hoc, des playbooks et des rôles.

### Démo 1 : Commande ad hoc pour vérifier la connectivité
- **Objectif** : Vérifier que les serveurs cibles sont accessibles par Ansible.
- **Commande** :
  ```bash
  ansible all -i inventory -m ping
  ```
- **Explication** :
  - **Module `ping`** vérifie la connectivité avec les hôtes définis dans l'inventaire (`inventory`).

### Démo 2 : Commande ad hoc pour installer un package
- **Objectif** : Installer `htop` sur les serveurs cibles.
- **Commande** :
  ```bash
  ansible all -i inventory -m apt -a "name=htop state=present" --become
  ```
- **Explication** :
  - Le module **`apt`** gère les packages sur les systèmes basés sur Debian. Ici, il installe `htop` avec l'option `--become` pour escalader les privilèges.

### Démo 3 : Utiliser une commande ad hoc pour gérer les services
- **Objectif** : Démarrer le service `nginx`.
- **Commande** :
  ```bash
  ansible all -i inventory -m service -a "name=nginx state=started" --become
  ```
- **Explication** :
  - Le module **`service`** gère les services. Ici, il démarre le service `nginx`.

### Démo 4 : Créer un playbook simple pour des tâches multiples
- **Objectif** : Automatiser les tâches de mise à jour et d’installation de `git`.
- **Playbook** (`update_install.yml`) :
  ```yaml
  ---
  - hosts: all
    become: yes
    tasks:
      - name: Update apt cache
        apt:
          update_cache: yes

      - name: Install git
        apt:
          name: git
          state: present
  ```
- **Exécution** :
  ```bash
  ansible-playbook -i inventory update_install.yml
  ```
- **Explication** :
  - Le playbook gère la mise à jour des paquets et installe `git` sur tous les hôtes.

### Démo 5 : Variables dans un playbook
- **Objectif** : Installer un package avec une variable.
- **Playbook** (`install_package.yml`) :
  ```yaml
  ---
  - hosts: all
    become: yes
    vars:
      package_name: curl
    tasks:
      - name: Install package
        apt:
          name: "{{ package_name }}"
          state: present
  ```
- **Exécution** :
  ```bash
  ansible-playbook -i inventory install_package.yml
  ```
- **Explication** :
  - Utilisation de la variable **`package_name`** pour installer un package.

### Démo 6 : Créer et gérer des utilisateurs avec un playbook
- **Objectif** : Créer un utilisateur `devuser` et définir son mot de passe.
- **Playbook** (`create_user.yml`) :
  ```yaml
  ---
  - hosts: all
    become: yes
    tasks:
      - name: Create user
        user:
          name: devuser
          password: "{{ 'password' | password_hash('sha512') }}"
  ```
- **Exécution** :
  ```bash
  ansible-playbook -i inventory create_user.yml
  ```
- **Explication** :
  - Utilisation du module **`user`** pour gérer les utilisateurs. Le mot de passe est crypté avec **`password_hash`**.

### Démo 7 : Utilisation des rôles Ansible
- **Objectif** : Structurer les tâches pour configurer `nginx` en utilisant un rôle.
- **Étapes** :
  1. **Créer un rôle Ansible** pour `nginx` :
     ```bash
     ansible-galaxy init nginx
     ```
  2. **Configurer les tâches dans `nginx/tasks/main.yml`** :
     ```yaml
     ---
     - name: Install nginx
       apt:
         name: nginx
         state: present
     - name: Start and enable nginx
       service:
         name: nginx
         state: started
         enabled: yes
     ```
  3. **Créer le playbook principal** (`site.yml`) :
     ```yaml
     ---
     - hosts: all
       become: yes
       roles:
         - nginx
     ```
- **Exécution** :
  ```bash
  ansible-playbook -i inventory site.yml
  ```
- **Explication** :
  - Les rôles permettent une organisation claire du code et facilitent la réutilisation.

### Démo 8 : Utiliser des templates Jinja2
- **Objectif** : Configurer un fichier `nginx.conf` personnalisé avec un template.
- **Étapes** :
  1. **Créer un template** dans `nginx/templates/nginx.conf.j2` :
     ```nginx
     server {
         listen 80;
         server_name {{ inventory_hostname }};
         location / {
             proxy_pass http://127.0.0.1:3000;
         }
     }
     ```
  2. **Ajouter la tâche pour copier le template** dans `nginx/tasks/main.yml` :
     ```yaml
     - name: Deploy nginx configuration from template
       template:
         src: nginx.conf.j2
         dest: /etc/nginx/nginx.conf
       notify: restart nginx
     ```
  3. **Gérer le handler pour redémarrer nginx** dans `nginx/handlers/main.yml` :
     ```yaml
     - name: restart nginx
       service:
         name: nginx
         state: restarted
     ```
- **Exécution** :
  ```bash
  ansible-playbook -i inventory site.yml
  ```
- **Explication** :
  - Utilisation de **templates Jinja2** pour configurer dynamiquement `nginx`.

### Démo 9 : Variables de groupe dans les inventaires
- **Objectif** : Différencier les configurations par groupe d’hôtes.
- **Étapes** :
  1. **Créer un inventaire avec des groupes** (`inventory`) :
     ```ini
     [web]
     web1 ansible_host=192.168.1.10
     web2 ansible_host=192.168.1.11

     [db]
     db1 ansible_host=192.168.1.20
     ```
  2. **Définir les variables par groupe** dans `group_vars/web.yml` :
     ```yaml
     ---
     server_port: 8080
     ```
  3. **Utiliser la variable `server_port`** dans un template ou une tâche.
- **Exécution** :
  ```bash
  ansible-playbook -i inventory site.yml
  ```
- **Explication** :
  - Les **variables de groupe** permettent des configurations spécifiques à chaque groupe d’hôtes.

### Démo 10 : Playbook multi-environnements avec des inventaires spécifiques
- **Objectif** : Gérer différents environnements (développement, production).
- **Étapes** :
  1. **Créer des inventaires pour chaque environnement** :
     - `inventories/dev` et `inventories/prod`.
  2. **Créer des variables spécifiques pour chaque environnement** dans `group_vars`.
  3. **Playbook multi-environnements** :
     ```yaml
     ---
     - hosts: all
       become: yes
       roles:
         - nginx
     ```
- **Exécution** :
  ```bash
  ansible-playbook -i inventories/dev site.yml
  ```
- **Explication** :
  - Facilite la gestion de configurations différentes entre les environnements.

### Démo 11 : Utiliser des `handlers` pour des configurations spécifiques
- **Objectif** : Déclencher des tâches conditionnelles via des `handlers`.
- **Playbook** :
  - Utilisez les handlers pour gérer des redémarrages conditionnels des services en cas de modification de la configuration.
  - Ex. : Redémarrer `nginx` uniquement si le fichier de configuration a changé.

### Démo 12 : Créer et utiliser un rôle personnalisé complexe
- **Objectif** : Créer un rôle pour déployer une application web (exemple Node.js).
- **Étapes** :
  1. **Structure du rôle `webapp`** avec des tâches pour :
     - Installer Node.js.
     - Copier l’application.
     - Démarrer le service via `systemd`.
  2. **Définir le rôle** dans `site.yml` :
     ```yaml
     ---
     - hosts: all
       become: yes
       roles:
         - webapp
     ```
  3. **Exécution et débogage avec des tags** :
     ```bash
     ansible-playbook -i inventory site.yml --tags "deploy"
     ```
- **Explication** :
  - Cette démo intègre une application complète, de l’installation à la gestion en service avec `systemd`.


