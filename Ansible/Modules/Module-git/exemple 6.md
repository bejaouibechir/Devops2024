# Module pour afficher la taille d'un fichier 

### 1. **Structure du module personnalisé**
Un module personnalisé Ansible nécessite :
- Un fichier Python (module) dans un sous-dossier spécifique de `library/`.
- Une fonction principale gérant la logique.
- Une gestion d'erreurs propre et conforme aux standards d'Ansible.

Structure :
```
custom_module/
├── ansible.cfg
├── inventory
├── playbook.yml
└── library/
    └── file_size.py
```

---

### 2. **Code source du module**
**Fichier** : `library/file_size.py`

```python
#!/usr/bin/python

from ansible.module_utils.basic import AnsibleModule
import os

def main():
    # Définition des arguments
    module_args = dict(
        path=dict(type='str', required=True)
    )
    
    # Initialisation du module
    module = AnsibleModule(argument_spec=module_args)
    
    # Récupération des paramètres
    file_path = module.params['path']
    
    # Validation et logique
    if not os.path.exists(file_path):
        module.fail_json(msg=f"File '{file_path}' does not exist.")
    
    if not os.path.isfile(file_path):
        module.fail_json(msg=f"'{file_path}' is not a file.")
    
    try:
        size = os.path.getsize(file_path)
        module.exit_json(changed=False, size=size)
    except Exception as e:
        module.fail_json(msg=str(e))

if __name__ == '__main__':
    main()
```

---

### 3. **Intégration et test**

#### a) Configuration de l'environnement
**Fichier** : `ansible.cfg`

```ini
[defaults]
inventory = inventory
library = library
```

**Fichier** : `inventory`

```
localhost ansible_connection=local
```

---

#### b) Création d'un fichier pour tester
Dans votre machine locale (ou EC2) :

```bash
echo "This is a test file" > test_file.txt
```

---

#### c) Création du playbook
**Fichier** : `playbook.yml`

```yaml
- name: Test custom Ansible module
  hosts: localhost
  tasks:
    - name: Check file size
      file_size:
        path: test_file.txt
      register: result
    
    - name: Display file size
      debug:
        msg: "The size of the file is {{ result.size }} bytes"
```

---

#### d) Exécution du test
Dans le dossier contenant les fichiers :

```bash
ansible-playbook playbook.yml
```

---

### Résultat attendu
- Si le fichier existe, le message affichera sa taille en octets.
- Si le fichier n'existe pas ou si une erreur se produit, un message d'erreur clair sera retourné.

---

Ce module montre comment :
1. Utiliser Python pour créer un module Ansible.
2. Intégrer un module personnalisé dans un projet.
3. Tester un module avec un playbook simple.
