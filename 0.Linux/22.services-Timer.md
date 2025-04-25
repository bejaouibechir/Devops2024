# Configuration de l'unité timer

### Scénario : Configuration de `systemd` pour exécuter deux applications Python à des intervalles différents via des **timers**

Dans ce scénario, nous allons créer deux services Python simples qui enregistrent l'heure à laquelle ils sont exécutés, puis configurer des **timers `systemd`** pour exécuter ces services à des intervalles différents.

### Objectif

1. Créer deux petites applications Python (`myapp` et `otherapp`).
2. Configurer des services `systemd` pour exécuter ces applications.
3. Configurer des timers `systemd` pour exécuter ces services à des fréquences différentes.

---

### Étapes

---

### **1. Créer deux applications Python simples**

Nous allons d'abord créer deux applications Python qui inscrivent l'heure d'exécution dans des fichiers log pour vérifier qu'elles sont exécutées par les timers à des moments différents.

#### a. **Application 1 : `myapp`**

- Créez un répertoire pour l'application `myapp` :

```bash
mkdir /usr/local/bin/myapp
cd /usr/local/bin/myapp
```

- Créez un fichier `app.py` pour `myapp` :

```python
# /usr/local/bin/myapp/app.py
import time
from datetime import datetime

def main():
    with open("/var/log/myapp_timer.log", "a") as log:
        log.write(f"myapp executed at {datetime.now()}\n")

if __name__ == "__main__":
    main()
```

Ce script inscrit l'heure d'exécution dans le fichier `/var/log/myapp_timer.log`.

#### b. **Application 2 : `otherapp`**

- Créez un répertoire pour `otherapp` :

```bash
mkdir /usr/local/bin/otherapp
cd /usr/local/bin/otherapp
```

- Créez le fichier `app.py` pour `otherapp` :

```python
# /usr/local/bin/otherapp/app.py
import time
from datetime import datetime

def main():
    with open("/var/log/otherapp_timer.log", "a") as log:
        log.write(f"otherapp executed at {datetime.now()}\n")

if __name__ == "__main__":
    main()
```

Ce script inscrit l'heure d'exécution dans le fichier `/var/log/otherapp_timer.log`.

---

### **2. Configurer les services `systemd` pour les deux applications**

Nous allons maintenant configurer les services `systemd` pour exécuter ces scripts Python lorsque leurs timers seront déclenchés.

#### a. **Créer le service `myapp.service`**

- Créez le fichier `/etc/systemd/system/myapp.service` :

```bash
sudo nano /etc/systemd/system/myapp.service
```

- Ajoutez le contenu suivant pour exécuter `myapp` :

```ini
[Unit]
Description=MyApp Timer Service

[Service]
Type=oneshot
ExecStart=/usr/bin/python3 /usr/local/bin/myapp/app.py
```

- Ce service est de type `oneshot` car il s'exécute une seule fois à chaque déclenchement du timer.

#### b. **Créer le service `otherapp.service`**

- Créez le fichier `/etc/systemd/system/otherapp.service` :

```bash
sudo nano /etc/systemd/system/otherapp.service
```

- Ajoutez le contenu suivant pour exécuter `otherapp` :

```ini
[Unit]
Description=OtherApp Timer Service

[Service]
Type=oneshot
ExecStart=/usr/bin/python3 /usr/local/bin/otherapp/app.py
```

---

### **3. Configurer des timers `systemd` pour les deux services**

Nous allons maintenant configurer deux timers `systemd` pour exécuter `myapp` et `otherapp` à des intervalles différents.

#### a. **Créer le timer pour `myapp`**

Le timer pour `myapp` va exécuter `myapp.service` toutes les **5 minutes**.

- Créez le fichier `/etc/systemd/system/myapp.timer` :

```bash
sudo nano /etc/systemd/system/myapp.timer
```

- Ajoutez le contenu suivant :

```ini
[Unit]
Description=Timer to run myapp every 5 minutes

[Timer]
OnBootSec=2min  # Démarre 2 minutes après le démarrage du système
OnUnitActiveSec=5min  # Exécute le service toutes les 5 minutes

[Install]
WantedBy=timers.target
```

#### b. **Créer le timer pour `otherapp`**

Le timer pour `otherapp` va exécuter `otherapp.service` toutes les **10 minutes**.

- Créez le fichier `/etc/systemd/system/otherapp.timer` :

```bash
sudo nano /etc/systemd/system/otherapp.timer
```

- Ajoutez le contenu suivant :

```ini
[Unit]
Description=Timer to run otherapp every 10 minutes

[Timer]
OnBootSec=1min  # Démarre 1 minute après le démarrage du système
OnUnitActiveSec=10min  # Exécute le service toutes les 10 minutes

[Install]
WantedBy=timers.target
```

---

### **4. Activer et démarrer les services et timers**

#### a. **Recharger `systemd` pour appliquer les modifications**

Rechargez `systemd` pour prendre en compte les nouveaux services et timers :

```bash
sudo systemctl daemon-reload
```

#### b. **Activer et démarrer les timers**

Activez et démarrez les deux timers :

```bash
sudo systemctl enable myapp.timer
sudo systemctl start myapp.timer

sudo systemctl enable otherapp.timer
sudo systemctl start otherapp.timer
```

#### c. **Vérifier les statuts des timers**

Vous pouvez vérifier que les timers fonctionnent en vérifiant leur statut :

```bash
sudo systemctl status myapp.timer
sudo systemctl status otherapp.timer
```

---

### **5. Vérification des journaux**

Pour vérifier que les services sont exécutés aux bons intervalles, consultez les fichiers de log :

#### a. **Vérifier le log de `myapp`**

```bash
cat /var/log/myapp_timer.log
```

Vous devriez voir des entrées toutes les 5 minutes.

#### b. **Vérifier le log de `otherapp`**

```bash
cat /var/log/otherapp_timer.log
```

Vous devriez voir des entrées toutes les 10 minutes.

---

### Conclusion

Dans ce scénario, vous avez appris à configurer deux services Python simples qui sont exécutés par des **timers `systemd`** à des intervalles différents. `myapp` est exécuté toutes les 5 minutes, tandis que `otherapp` est exécuté toutes les 10 minutes. Grâce à l'utilisation des timers, vous pouvez planifier l'exécution automatique de tâches à des moments précis, similaire à `cron`, mais avec plus de flexibilité et une meilleure intégration avec `systemd`.
