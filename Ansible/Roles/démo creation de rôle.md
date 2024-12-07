# Rôle pour installer Docker sur des machines ***Ubuntu*** et ***CentOS***.

### Structure des Dossiers et des Fichiers pour l'Installation de Docker

```
project-root/
├── roles/
│   └── install_docker/
│       ├── tasks/
│       │   ├── main.yml                 # Tâches principales du rôle
│       │   ├── install_docker_ubuntu.yml  # Installation de Docker sur Ubuntu
│       │   └── install_docker_centos.yml  # Installation de Docker sur CentOS
│       └── meta/
│           └── main.yml                 # Métadonnées du rôle
├── playbook.yml                         # Playbook principal qui appelle le rôle
└── inventory                            # Inventaire des hôtes avec catégories Ubuntu et CentOS
```

### 1. Tâches Principales (tasks/main.yml)

Dans `main.yml`, nous incluons les tâches spécifiques à Ubuntu et CentOS en fonction du système d’exploitation détecté.

**Fichier : `roles/install_docker/tasks/main.yml`**

```yaml
---
- name: Installer Docker sur Ubuntu
  include_tasks: install_docker_ubuntu.yml
  when: ansible_os_family == "Debian"

- name: Installer Docker sur CentOS
  include_tasks: install_docker_centos.yml
  when: ansible_os_family == "RedHat"

- name: Démarrer et activer Docker
  service:
    name: docker
    state: started
    enabled: true
```

### 2. Tâche pour Installer Docker sur Ubuntu (tasks/install_docker_ubuntu.yml)

Ce fichier contient les commandes pour installer Docker sur une machine Ubuntu.

**Fichier : `roles/install_docker/tasks/install_docker_ubuntu.yml`**

```yaml
---
- name: Mettre à jour la liste des paquets
  apt:
    update_cache: yes

- name: Installer les dépendances Docker sur Ubuntu
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - apt-transport-https
    - ca-certificates
    - curl
    - software-properties-common

- name: Ajouter la clé GPG Docker pour Ubuntu
  apt_key:
    url: https://download.docker.com/linux/ubuntu/gpg
    state: present

- name: Ajouter le dépôt Docker pour Ubuntu
  apt_repository:
    repo: "deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
    state: present

- name: Installer Docker
  apt:
    name: docker-ce
    state: present
```

### 3. Tâche pour Installer Docker sur CentOS (tasks/install_docker_centos.yml)

Ce fichier contient les commandes pour installer Docker sur une machine CentOS.

**Fichier : `roles/install_docker/tasks/install_docker_centos.yml`**

```yaml
---
- name: Installer les dépendances Docker sur CentOS
  yum:
    name: "{{ item }}"
    state: present
  loop:
    - yum-utils
    - device-mapper-persistent-data
    - lvm2

- name: Ajouter le dépôt Docker pour CentOS
  command: >
    yum-config-manager --add-repo
    https://download.docker.com/linux/centos/docker-ce.repo

- name: Installer Docker
  yum:
    name: docker-ce
    state: present
```

### 4. Métadonnées du Rôle (meta/main.yml)

Ajoutez des informations de base pour le rôle, bien qu'aucune dépendance ne soit requise ici.

**Fichier : `roles/install_docker/meta/main.yml`**

```yaml
---
dependencies: []
```

### Inventaire (inventory)

Définissez vos hôtes dans l’inventaire en les catégorisant en `ubuntu` et `centos`.

**Fichier : `inventory`**

```ini
[ubuntu]
ubuntu_host ansible_host=192.168.1.10 ansible_user=your_user ansible_ssh_private_key_file=your_key.pem ansible_become=yes

[centos]
centos_host ansible_host=192.168.1.20 ansible_user=your_user ansible_ssh_private_key_file=your_key.pem ansible_become=yes
```

### Playbook Principal (playbook.yml)

Le playbook principal utilise le rôle `install_docker` pour installer Docker sur toutes les machines définies dans l’inventaire.

**Fichier : `playbook.yml`**

```yaml
---
- name: Installation de Docker sur Ubuntu et CentOS
  hosts: all
  become: yes
  roles:
    - install_docker
```

### Exécution du Playbook

Depuis le répertoire `project-root`, exécutez le playbook :

```bash
ansible-playbook -i inventory playbook.yml
```

### Résumé

Ce playbook et rôle Ansible vont :
- Installer Docker sur les machines Ubuntu et CentOS en détectant automatiquement le système d'exploitation.
- Démarrer et activer le service Docker sur chaque machine.

Cette version simplifiée se concentre uniquement sur l’installation de Docker sans déploiement d’une image Dockerisée comme Nginx.
