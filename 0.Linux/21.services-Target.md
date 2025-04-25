# Exemple de configuration de target selon deux scénarios

### Scénario : Configuration de `custom.target` pour lancer deux services soit **simultanément** soit **l’un après l’autre**

Dans ce scénario, nous allons étendre l'exemple précédent pour démontrer comment configurer un **target personnalisé** qui permet de :

1. **Scénario 1** : Démarrer les deux services Python **simultanément**.
2. **Scénario 2** : Démarrer les deux services **l'un après l'autre**, où `otherapp` démarre seulement après que `myapp` soit complètement démarré.

Nous allons également modifier les deux applications Python pour qu'elles écrivent l'heure de démarrage dans un fichier log, afin de prouver si elles se lancent simultanément ou séquentiellement.

---

### **1. Ajouter l'heure de démarrage aux deux applications Python**

Nous allons d'abord modifier les deux applications Python pour qu'elles inscrivent l'heure de démarrage dans un fichier log.

#### a. **Modification de `myapp`**

Ouvrez le fichier `/usr/local/bin/myapp/app.py` et modifiez-le comme suit :

```python
import time
from datetime import datetime

def main():
    with open("/var/log/myapp.log", "a") as log:
        log.write(f"myapp started at {datetime.now()}\n")
    
    print("myapp is starting...")
    while True:
        time.sleep(5)
        print("myapp is running")

if __name__ == "__main__":
    main()
```

Ce script écrit l'heure de démarrage dans `/var/log/myapp.log`.

#### b. **Modification de `otherapp`**

Faites la même chose pour `otherapp`. Ouvrez le fichier `/usr/local/bin/otherapp/app.py` et modifiez-le comme suit :

```python
import time
from datetime import datetime

def main():
    with open("/var/log/otherapp.log", "a") as log:
        log.write(f"otherapp started at {datetime.now()}\n")
    
    print("otherapp is starting...")
    while True:
        time.sleep(5)
        print("otherapp is running")

if __name__ == "__main__":
    main()
```

Ce script écrit l'heure de démarrage dans `/var/log/otherapp.log`.

---

### **2. Scénario 1 : Lancer les deux services simultanément**

Dans ce scénario, nous allons configurer `systemd` pour lancer `myapp` et `otherapp` simultanément. Nous utilisons ici notre target personnalisé, mais les services ne dépendront pas les uns des autres.

#### a. **Configurer les fichiers de service**

Assurez-vous que les fichiers de service suivants sont bien configurés avec la dépendance vers `custom.target` mais sans dépendances entre eux.

##### `myapp.service` :

```ini
[Unit]
Description=MyApp Service
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/myapp/app.py
Restart=on-failure
User=<user>
WorkingDirectory=/usr/local/bin/myapp

[Install]
WantedBy=custom.target
```

##### `otherapp.service` :

```ini
[Unit]
Description=OtherApp Service
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/otherapp/app.py
Restart=on-failure
User=<user>
WorkingDirectory=/usr/local/bin/otherapp

[Install]
WantedBy=custom.target
```

#### b. **Configurer le target `custom.target`**

Le fichier du target `custom.target` reste le même pour lancer les deux services simultanément.

- Créez ou éditez le fichier `/etc/systemd/system/custom.target` :

```ini
[Unit]
Description=Custom Target to start myapp and otherapp
Requires=myapp.service otherapp.service
After=network.target

[Install]
WantedBy=multi-user.target
```

#### c. **Démarrer le target personnalisé**

Rechargez `systemd`, puis démarrez le target :

```bash
sudo systemctl daemon-reload
sudo systemctl start custom.target
```

#### d. **Vérification**

Vérifiez les fichiers de log `/var/log/myapp.log` et `/var/log/otherapp.log` pour voir si les deux services se sont lancés en même temps :

```bash
cat /var/log/myapp.log
cat /var/log/otherapp.log
```

Vous devriez voir que les heures de démarrage sont très proches, indiquant que les services se sont lancés simultanément.

---

### **3. Scénario 2 : Lancer les deux services l'un après l'autre**

Dans ce scénario, nous allons configurer `systemd` pour que `otherapp` démarre uniquement après que `myapp` soit complètement démarré.

#### a. **Configurer les fichiers de service pour démarrage séquentiel**

Nous devons ajuster la configuration de `otherapp` pour indiquer qu'il dépend du démarrage complet de `myapp`.

##### `myapp.service` :

Ce fichier reste le même.

```ini
[Unit]
Description=MyApp Service
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/myapp/app.py
Restart=on-failure
User=<user>
WorkingDirectory=/usr/local/bin/myapp

[Install]
WantedBy=custom.target
```

##### `otherapp.service` :

Nous modifions le fichier de `otherapp` pour ajouter une dépendance sur `myapp`.

```ini
[Unit]
Description=OtherApp Service
After=myapp.service network.target  # otherapp doit attendre que myapp soit démarré

[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/otherapp/app.py
Restart=on-failure
User=<user>
WorkingDirectory=/usr/local/bin/otherapp

[Install]
WantedBy=custom.target
```

#### b. **Configurer le target `custom.target`**

Le fichier `custom.target` reste inchangé, car il ne fait que lier les services. L'ordre de démarrage est géré dans les services eux-mêmes.

- Vérifiez que `/etc/systemd/system/custom.target` contient ceci :

```ini
[Unit]
Description=Custom Target to start myapp and otherapp
Requires=myapp.service otherapp.service
After=network.target

[Install]
WantedBy=multi-user.target
```

#### c. **Démarrer le target personnalisé**

Rechargez `systemd`, puis démarrez le target :

```bash
sudo systemctl daemon-reload
sudo systemctl start custom.target
```

#### d. **Vérification**

Vérifiez les fichiers de log `/var/log/myapp.log` et `/var/log/otherapp.log` pour confirmer que `otherapp` s'est bien lancé après `myapp`.

```bash
cat /var/log/myapp.log
cat /var/log/otherapp.log
```

Les horodatages doivent montrer que `otherapp` s'est lancé après `myapp`.

---

### Conclusion

Dans ce guide, vous avez appris à configurer deux scénarios de démarrage avec un **target personnalisé** :

1. **Scénario 1** : Les deux services Python (`myapp` et `otherapp`) se lancent **simultanément**, sans dépendances entre eux.
2. **Scénario 2** : `otherapp` se lance **après** `myapp`, grâce à l'ajout de dépendances dans la configuration du service.

En utilisant les fichiers de log, nous pouvons confirmer dans chaque scénario si les services démarrent en parallèle ou de manière séquentielle. Ces techniques sont utiles dans des environnements de production où l'ordre de démarrage des services est critique pour assurer la bonne fonction des applications interdépendantes.
