# Création du module create user

### Structure des Dossiers pour le Module Personnalisé

```
project-root/
├── library/
│   └── manage_user.py                # Module personnalisé pour gérer les utilisateurs
└── create-user.yml                   # Playbook utilisant le module manage_user
```

### 1. Module Personnalisé : `manage_user.py`

Le module `manage_user.py` crée un utilisateur sur la machine cible avec une description personnalisée et un répertoire personnel spécifique.

**Fichier : `project-root/library/manage_user.py`**

```python
#!/usr/bin/python
from ansible.module_utils.basic import AnsibleModule
import os
import pwd
import subprocess

def create_user(module, username, description, home_dir):
    # Vérifier si l'utilisateur existe déjà
    try:
        pwd.getpwnam(username)
        user_exists = True
    except KeyError:
        user_exists = False

    # Créer l'utilisateur s'il n'existe pas
    if not user_exists:
        cmd = ["useradd", "-m", "-c", description, "-d", home_dir, username]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            module.fail_json(msg="Erreur lors de la création de l'utilisateur", stderr=result.stderr)
        user_created = True
    else:
        user_created = False

    # Créer le répertoire personnel si nécessaire
    if not os.path.exists(home_dir):
        os.makedirs(home_dir, exist_ok=True)
        os.chown(home_dir, pwd.getpwnam(username).pw_uid, pwd.getpwnam(username).pw_gid)
        dir_created = True
    else:
        dir_created = False

    return user_created, dir_created

def main():
    module_args = dict(
        username=dict(type='str', required=True),
        description=dict(type='str', default=""),
        home_dir=dict(type='str', required=True)
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    username = module.params['username']
    description = module.params['description']
    home_dir = module.params['home_dir']

    try:
        user_created, dir_created = create_user(module, username, description, home_dir)
        module.exit_json(changed=user_created or dir_created, user_created=user_created, dir_created=dir_created)
    except Exception as e:
        module.fail_json(msg=str(e))

if __name__ == '__main__':
    main()
```

### 2. Playbook pour Utiliser le Module Personnalisé : `create-user.yml`

Ce playbook utilise le module `manage_user` pour créer un utilisateur avec une description et un répertoire personnel.

**Fichier : `project-root/create-user.yml`**

```yaml
---
- name: Gestion d'un utilisateur spécifique avec module personnalisé
  hosts: localhost
  tasks:
    - name: Créer l'utilisateur avec une description et un répertoire personnel
      manage_user:
        username: "customuser"
        description: "Utilisateur spécifique avec dossier dédié"
        home_dir: "/home/customuser"
```

### Exécution du Playbook

Assurez-vous d'être dans le répertoire `project-root`, puis exécutez le playbook :

```bash
ansible-playbook -i localhost, create-user.yml
```
