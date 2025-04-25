# Création du module personnalisé

Voici la structure des dossiers pour le **plugin de filtre personnalisé** ainsi que le contenu du plugin et du playbook.

### Structure des Dossiers pour le Plugin de Filtre Personnalisé

```
project-root/
├── filter_plugins/
│   └── ip_filters.py                 # Plugin de filtre pour filtrer les adresses IP privées
└── filter-ips.yml                    # Playbook utilisant le plugin de filtre ip_filters
```

### 1. Plugin de Filtre Personnalisé : `ip_filters.py`

Le plugin `ip_filters.py` prend une liste d'adresses IP et filtre celles qui sont dans des plages d'adresses privées.

**Fichier : `project-root/filter_plugins/ip_filters.py`**

```python
from ansible.errors import AnsibleFilterError
import ipaddress

def filter_private_ips(ip_list):
    if not isinstance(ip_list, list):
        raise AnsibleFilterError("Expected a list of IP addresses")

    private_ips = [ip for ip in ip_list if ipaddress.ip_address(ip).is_private]
    return private_ips

class FilterModule(object):
    def filters(self):
        return {
            'filter_private_ips': filter_private_ips
        }
```

### 2. Playbook pour Utiliser le Plugin de Filtre Personnalisé : `filter-ips.yml`

Ce playbook utilise le plugin de filtre `filter_private_ips` pour afficher uniquement les adresses IP privées dans une liste donnée.

**Fichier : `project-root/filter-ips.yml`**

```yaml
---
- name: Filtrage des adresses IP privées avec plugin de filtre personnalisé
  hosts: localhost
  vars:
    ip_addresses:
      - "192.168.1.10"
      - "8.8.8.8"
      - "10.0.0.5"
      - "172.16.0.1"
  tasks:
    - name: Afficher les adresses IP privées
      debug:
        msg: "{{ ip_addresses | filter_private_ips }}"
```

### Exécution du Playbook

Assurez-vous d'être dans le répertoire `project-root`, puis exécutez le playbook :

```bash
ansible-playbook -i localhost, filter-ips.yml
```

### Résultat Attendu

Le playbook affichera uniquement les adresses IP privées de la liste :

```
TASK [Afficher les adresses IP privées] ****************************************************************
ok: [localhost] => {
    "msg": [
        "192.168.1.10",
        "10.0.0.5",
        "172.16.0.1"
    ]
}
```
