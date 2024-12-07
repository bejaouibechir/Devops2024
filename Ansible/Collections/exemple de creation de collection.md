## Créer une collection Ansible

Pour créer une **collection Ansible** qui regroupe plusieurs rôles et des composants personnalisés (un module et un plugin), voici les étapes à suivre. Je vais commencer par montrer comment structurer la collection, puis comment déployer celle-ci sur Ansible Galaxy.

### Structure de la Collection

Voici la structure du projet Ansible pour la collection. Cette collection contient :
- Deux rôles : un pour installer et un pour désinstaller Docker, ainsi qu'un pour déployer une version dockerisée de Nginx.
- Un module personnalisé pour créer un utilisateur.
- Un plugin pour notifier par email l’utilisateur que le playbook a été exécuté avec succès.

```
my_namespace/
└── docker_management/
    ├── README.md                        # Documentation de la collection
    ├── galaxy.yml                       # Fichier de configuration de la collection
    ├── roles/
    │   ├── install_docker/              # Rôle pour installer Docker
    │   │   └── tasks/
    │   │       └── main.yml
    │   ├── uninstall_docker/            # Rôle pour désinstaller Docker
    │   │   └── tasks/
    │   │       └── main.yml
    │   └── deploy_nginx/                # Rôle pour déployer Nginx avec Docker
    │       └── tasks/
    │           └── main.yml
    ├── plugins/
    │   ├── modules/
    │   │   └── create_user.py           # Module personnalisé pour créer un utilisateur
    │   └── callback/
    │       └── email_notify.py          # Plugin de notification par email
    └── playbooks/
        ├── install_docker.yml           # Playbook d'installation de Docker
        ├── uninstall_docker.yml         # Playbook de désinstallation de Docker
        └── deploy_nginx.yml             # Playbook de déploiement de Nginx
```

### Étape 1 : Configuration de la Collection (`galaxy.yml`)

Le fichier `galaxy.yml` définit les métadonnées de la collection, telles que le nom, l’auteur, et la version.

**Fichier : `my_namespace/docker_management/galaxy.yml`**

```yaml
namespace: my_namespace
name: docker_management
version: 1.0.0
author: "Votre Nom"
description: "Collection pour gérer l'installation et la gestion de Docker et de Nginx dans des conteneurs, avec un module pour créer des utilisateurs et un plugin de notification."
license: MIT
dependencies: {}
```

### Étape 2 : Création des Rôles

#### Rôle `install_docker` (roles/install_docker/tasks/main.yml)

Ce rôle installe Docker en fonction du système d’exploitation.

**Fichier : `roles/install_docker/tasks/main.yml`**

```yaml
---
- name: Installer Docker
  include_tasks: "{{ ansible_os_family | lower }}_install_docker.yml"

# Tâches spécifiques pour Ubuntu (roles/install_docker/tasks/ubuntu_install_docker.yml)
- name: Installer les dépendances pour Docker sur Ubuntu
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - apt-transport-https
    - ca-certificates
    - curl
    - software-properties-common

# Ajouter d'autres tâches nécessaires pour CentOS...
```

#### Rôle `uninstall_docker` (roles/uninstall_docker/tasks/main.yml)

Ce rôle désinstalle Docker.

**Fichier : `roles/uninstall_docker/tasks/main.yml`**

```yaml
---
- name: Désinstaller Docker
  package:
    name: docker
    state: absent
```

#### Rôle `deploy_nginx` (roles/deploy_nginx/tasks/main.yml)

Ce rôle déploie Nginx dans un conteneur Docker.

**Fichier : `roles/deploy_nginx/tasks/main.yml`**

```yaml
---
- name: Télécharger l'image Nginx
  community.docker.docker_image:
    name: nginx:latest

- name: Démarrer le conteneur Nginx
  community.docker.docker_container:
    name: nginx_container
    image: nginx:latest
    state: started
    ports:
      - "80:80"
```

### Étape 3 : Module Personnalisé `create_user`

Le module `create_user.py` crée un utilisateur avec un répertoire personnel.

**Fichier : `plugins/modules/create_user.py`**

```python
#!/usr/bin/python
from ansible.module_utils.basic import AnsibleModule
import os
import pwd
import subprocess

def main():
    module_args = dict(
        username=dict(type='str', required=True),
        home_dir=dict(type='str', required=True)
    )
    
    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)

    username = module.params['username']
    home_dir = module.params['home_dir']

    # Création de l'utilisateur
    subprocess.run(["useradd", "-m", "-d", home_dir, username], check=True)
    
    module.exit_json(changed=True, msg=f"Utilisateur {username} créé avec succès.")

if __name__ == '__main__':
    main()
```

### Étape 4 : Plugin de Notification par Email `email_notify`

Ce plugin envoie une notification par email à l’utilisateur après l’exécution d’un playbook.

**Fichier : `plugins/callback/email_notify.py`**

```python
from ansible.plugins.callback import CallbackBase
import smtplib
from email.message import EmailMessage

class CallbackModule(CallbackBase):
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'notification'
    CALLBACK_NAME = 'email_notify'

    def v2_playbook_on_stats(self, stats):
        email = EmailMessage()
        email.set_content("Le playbook a été exécuté avec succès.")
        email["Subject"] = "Notification Ansible : Playbook terminé"
        email["From"] = "your_email@example.com"
        email["To"] = "user@example.com"

        with smtplib.SMTP("localhost") as smtp:
            smtp.send_message(email)
```

### Étape 5 : Playbooks

Vous pouvez créer des playbooks pour exécuter chaque rôle dans le dossier `playbooks/`.

**Exemple : Playbook pour Installer Docker (playbooks/install_docker.yml)**

```yaml
---
- name: Installer Docker
  hosts: all
  become: yes
  roles:
    - my_namespace.docker_management.install_docker
```

### Déployer la Collection sur Ansible Galaxy

1. **Créer un Compte sur Ansible Galaxy** : Allez sur [galaxy.ansible.com](https://galaxy.ansible.com) et créez un compte si vous n'en avez pas déjà un.

2. **Configurer le Namespace** : Allez dans votre compte et configurez votre namespace `my_namespace`.

3. **Construire la Collection** : Depuis le répertoire `my_namespace/docker_management`, exécutez la commande suivante pour créer un package `.tar.gz` de la collection.

   ```bash
   ansible-galaxy collection build
   ```

   Cela générera un fichier `.tar.gz` dans le répertoire `my_namespace/docker_management/`.

4. **Publier la Collection** : Une fois que le package est créé, publiez-le sur Ansible Galaxy avec la commande suivante :

   ```bash
   ansible-galaxy collection publish my_namespace-docker_management-1.0.0.tar.gz
   ```

5. **Installer la Collection** : Après la publication, les autres utilisateurs peuvent installer votre collection avec :

   ```bash
   ansible-galaxy collection install my_namespace.docker_management
   ```

### Résumé

Vous avez maintenant une collection Ansible qui inclut :
- **Trois rôles** : pour installer Docker, désinstaller Docker, et déployer Nginx dans un conteneur Docker.
- **Un module personnalisé** : pour créer des utilisateurs.
- **Un plugin de notification** : pour envoyer un email après l'exécution d'un playbook.

Cette collection peut être partagée sur Ansible Galaxy pour une réutilisation facile.
