# Creation d'un  serivice simple

Voici un **scénario complet** combinant la **création d'une application Flask** (ou tout autre service) et sa **surveillance avec un service personnalisé `systemd`**.
Ce guide complet vous montrera comment déployer une application web simple et mettre en place un service qui la surveille et redémarre automatiquement en cas d'échec.

### Objectif

1. Créer une application Flask (notre application `myapp`).
2. Configurer un service `systemd` pour gérer et démarrer cette application.
3. Créer un second service `systemd` personnalisé pour surveiller l’application et la redémarrer si elle échoue.

### Étapes

---

### **1. Créer l'application Flask `myapp`**

#### a. **Installer Flask**

Commencez par installer Flask et ses dépendances sur votre système :

```bash
sudo apt update
sudo apt install python3 python3-pip
pip3 install flask
```

#### b. **Créer l'application Flask**

- Créez un répertoire pour héberger l’application :

```bash
mkdir /usr/local/bin/myapp
cd /usr/local/bin/myapp
```

- Créez le fichier principal de l’application `app.py` :

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, this is myapp!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

#### c. **Tester l'application**

Exécutez l'application pour vérifier qu'elle fonctionne correctement :

```bash
python3 /usr/local/bin/myapp/app.py
```

- Ouvrez un navigateur et allez à `http://<votre_serveur>:5000` (ou `http://localhost:5000`). Vous devriez voir le message **"Hello, this is myapp!"**.

---

### **2. Configurer un service `systemd` pour gérer l'application Flask**

Nous allons créer un service `systemd` qui démarrera l'application Flask automatiquement au démarrage du serveur et s'assurera qu'elle fonctionne en permanence.

#### a. **Créer un script pour démarrer l'application Flask**

Nous allons écrire un petit script bash pour lancer l'application Flask.

- Créez le script `/usr/local/bin/myapp.sh` :

```bash
#!/bin/bash
cd /usr/local/bin/myapp
exec python3 app.py
```

- Rendez le script exécutable :

```bash
sudo chmod +x /usr/local/bin/myapp.sh
```

#### b. **Créer le fichier de service `systemd`**

Ensuite, créez un fichier de configuration pour `systemd` dans `/etc/systemd/system/myapp.service` :

```ini
[Unit]
Description=Flask Web Application - myapp
After=network.target

[Service]
User=appuser  # Remplacez par l'utilisateur sous lequel l'application doit s'exécuter
WorkingDirectory=/usr/local/bin/myapp
ExecStart=/usr/local/bin/myapp.sh
Restart=always  # Redémarre automatiquement en cas de crash
RestartSec=10   # Attendre 10 secondes avant de redémarrer
Environment=FLASK_ENV=production  # Environnement Flask en production

[Install]
WantedBy=multi-user.target
```

#### c. **Activer et démarrer le service**

- Rechargez la configuration `systemd` :

```bash
sudo systemctl daemon-reload
```

- Activez le service pour qu’il se lance au démarrage du système :

```bash
sudo systemctl enable myapp.service
```

- Démarrez le service :

```bash
sudo systemctl start myapp.service
```

#### d. **Vérifier le statut du service**

Vérifiez que l’application est bien démarrée par `systemd` :

```bash
sudo systemctl status myapp.service
```

Si tout fonctionne, vous devriez voir que `myapp.service` est en cours d’exécution. Testez à nouveau l'application en visitant `http://<votre_serveur>:5000`.

---

### **3. Créer un service de surveillance pour l'application Flask**

Pour garantir que l’application est toujours en cours d’exécution, nous allons créer un second service `systemd` qui surveille l'application `myapp` et redémarre le service si nécessaire.

#### a. **Écrire un script de surveillance**

Créez un script qui vérifie si `myapp` fonctionne et redémarre le service si l’application est tombée.

- Créez le fichier `/usr/local/bin/check_myapp.sh` :

```bash
#!/bin/bash
if ! pgrep -f "python3 app.py" > /dev/null
then
    echo "myapp is down, restarting it..."
    systemctl restart myapp.service
else
    echo "myapp is running"
fi
```

- Rendez le script exécutable :

```bash
sudo chmod +x /usr/local/bin/check_myapp.sh
```

#### b. **Créer le fichier de service `systemd` pour la surveillance**

Nous allons maintenant créer un service `systemd` pour exécuter ce script de surveillance régulièrement.

- Créez le fichier `/etc/systemd/system/check-myapp.service` :

```ini
[Unit]
Description=Service to monitor and restart myapp if it crashes
After=network.target

[Service]
ExecStart=/usr/local/bin/check_myapp.sh
Restart=always  # Redémarre le service si le script échoue
Type=simple
User=appuser  # Remplacez par l'utilisateur adéquat

[Install]
WantedBy=multi-user.target
```

#### c. **Créer un timer pour exécuter le script de manière régulière**

Pour exécuter le script de surveillance à intervalles réguliers, nous allons utiliser un **timer** systemd.

- Créez le fichier `/etc/systemd/system/check-myapp.timer` :

```ini
[Unit]
Description=Run check-myapp.service every 5 minutes

[Timer]
OnBootSec=2min   # Attendre 2 minutes après le démarrage
OnUnitActiveSec=5min  # Exécuter toutes les 5 minutes

[Install]
WantedBy=timers.target
```

#### d. **Activer et démarrer le service et le timer**

- Rechargez `systemd` pour prendre en compte les nouvelles unités :

```bash
sudo systemctl daemon-reload
```

- Activez et démarrez le **service de surveillance** et le **timer** :

```bash
sudo systemctl enable check-myapp.service
sudo systemctl start check-myapp.service

sudo systemctl enable check-myapp.timer
sudo systemctl start check-myapp.timer
```

#### e. **Vérifier le bon fonctionnement**

Vérifiez le statut du timer et du service pour vous assurer qu’ils fonctionnent correctement :

```bash
sudo systemctl status check-myapp.service
sudo systemctl status check-myapp.timer
```

---

### Conclusion

Vous avez maintenant un système complet qui :

1. **Exécute une application Flask** via un service `systemd` (`myapp.service`).
2. **Surveille cette application** avec un second service `systemd` (`check-myapp.service`), qui vérifie régulièrement l'état de l'application.
3. **Redémarre automatiquement l'application** en cas de défaillance, garantissant ainsi sa haute disponibilité.

Ce scénario est typique pour les applications en production où la disponibilité est critique, et il montre comment utiliser `systemd` à la fois pour le lancement et la surveillance d'applications.
