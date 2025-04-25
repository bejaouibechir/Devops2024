# Le service OneShot

### Scénario : Création d’un service personnalisé de type *forking* pour un serveur Node.js en arrière-plan

Dans ce scénario, nous allons créer un **service `systemd` de type forking** qui gère un serveur Node.js qui se lance en arrière-plan (mode *daemon*). Le mode *forking* est utilisé lorsque le processus principal se détache du terminal et génère un processus enfant en arrière-plan. Nous allons également mettre en place un mécanisme de surveillance pour redémarrer ce serveur en cas de défaillance.

### Objectif

1. Créer une application Node.js qui fonctionne en mode *daemon* (en arrière-plan).
2. Configurer un service `systemd` de type *forking* pour gérer l'application.
3. Mettre en place un service de surveillance pour s'assurer que le serveur redémarre automatiquement en cas d'échec.

### Étapes

---

### **1. Créer l'application Node.js**

#### a. **Installer Node.js**

Commencez par installer Node.js sur votre système Ubuntu :

```bash
sudo apt update
sudo apt install nodejs
sudo apt install npm
```

Vérifiez que Node.js est bien installé :

```bash
node -v
npm -v
```

#### b. **Créer le serveur Node.js**

- Créez un répertoire pour l’application :

```bash
mkdir /usr/local/bin/myapp
cd /usr/local/bin/myapp
```

- Créez un fichier `server.js` pour l'application Node.js :

```javascript
const http = require('http');
const hostname = '0.0.0.0';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello, this is myapp running in daemon mode!\n');
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
```

#### c. **Installer `pm2` pour exécuter l'application en mode *forking***

`pm2` est un gestionnaire de processus populaire pour Node.js qui permet d'exécuter des applications en mode *forking* (en arrière-plan) et de les surveiller. Installez-le globalement avec npm :

```bash
sudo npm install -g pm2
```

Lancez l'application avec `pm2` en mode *daemon* :

```bash
pm2 start /usr/local/bin/myapp/server.js --name "myapp"
```

Vous pouvez vérifier que le serveur est en arrière-plan avec :

```bash
pm2 status
```

---

### **2. Configurer un service `systemd` de type *forking* pour gérer l'application Node.js**

Nous allons maintenant configurer `systemd` pour gérer l'exécution de cette application en mode *forking*, ce qui signifie que l’application se détachera du terminal et continuera de fonctionner en arrière-plan.

#### a. **Créer le fichier de service `systemd`**

Créez un fichier de service `systemd` dans `/etc/systemd/system/myapp.service` :

```ini
[Unit]
Description=Node.js Daemon - myapp
After=network.target

[Service]
ExecStart=/usr/bin/pm2 start /usr/local/bin/myapp/server.js --name "myapp" --no-daemon
ExecStop=/usr/bin/pm2 stop "myapp"
ExecReload=/usr/bin/pm2 reload "myapp"
PIDFile=/home/<user>/.pm2/pids/myapp-0.pid
Type=forking  # Service de type forking
User=<user>  # Remplacez <user> par l'utilisateur qui doit exécuter l'application
WorkingDirectory=/usr/local/bin/myapp
Restart=on-failure  # Redémarre uniquement en cas d'échec
RestartSec=10  # Attendre 10 secondes avant de redémarrer

[Install]
WantedBy=multi-user.target
```

#### b. **Activer et démarrer le service `systemd`**

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

#### c. **Vérifier le statut du service**

Vérifiez que le service est bien en cours d'exécution :

```bash
sudo systemctl status myapp.service
```

Vous devriez voir que le service `myapp` est en cours d'exécution en mode *daemon*.

---

### **3. Créer un service de surveillance pour l'application Node.js**

Pour garantir que l’application fonctionne en continu, nous allons créer un second service `systemd` qui surveille si l'application est toujours en cours d'exécution et la redémarre si nécessaire.

#### a. **Écrire un script de surveillance**

Créez un script qui vérifie si l’application fonctionne en arrière-plan et redémarre le service si nécessaire.

- Créez le fichier `/usr/local/bin/check_myapp.sh` :

```bash
#!/bin/bash
if ! pgrep -f "pm2: myapp" > /dev/null
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

#### b. **Créer un service `systemd` pour surveiller l'application**

Créez un fichier de service `systemd` pour exécuter ce script de surveillance régulièrement.

- Créez le fichier `/etc/systemd/system/check-myapp.service` :

```ini
[Unit]
Description=Monitor and restart myapp if it crashes
After=network.target

[Service]
ExecStart=/usr/local/bin/check_myapp.sh
Restart=always  # Redémarre le service si le script échoue
Type=simple
User=<user>  # Remplacez <user> par l'utilisateur adéquat

[Install]
WantedBy=multi-user.target
```

#### c. **Configurer un timer pour surveiller régulièrement l'application**

Nous allons configurer un timer pour exécuter le script de surveillance à des intervalles réguliers (par exemple toutes les 5 minutes).

- Créez le fichier `/etc/systemd/system/check-myapp.timer` :

```ini
[Unit]
Description=Run check-myapp.service every 5 minutes

[Timer]
OnBootSec=2min  # Attendre 2 minutes après le démarrage
OnUnitActiveSec=5min  # Exécuter toutes les 5 minutes

[Install]
WantedBy=timers.target
```

#### d. **Activer et démarrer le service et le timer**

- Rechargez `systemd` :

```bash
sudo systemctl daemon-reload
```

- Activez et démarrez le service et le timer de surveillance :

```bash
sudo systemctl enable check-myapp.service
sudo systemctl start check-myapp.service

sudo systemctl enable check-myapp.timer
sudo systemctl start check-myapp.timer
```

#### e. **Vérifier le bon fonctionnement**

Vérifiez que le service de surveillance fonctionne correctement :

```bash
sudo systemctl status check-myapp.service
sudo systemctl status check-myapp.timer
```

---

### Conclusion

Vous avez maintenant un **système complet** pour :

1. **Lancer une application Node.js** en mode *forking* à l’aide de `pm2` et géré par `systemd`.
2. **Superviser cette application** en utilisant un second service `systemd` qui vérifie si l’application est en cours d’exécution toutes les 5 minutes et la redémarre si nécessaire.
3. **Redémarrer automatiquement l'application** en cas d’échec, assurant ainsi une haute disponibilité.

Ce scénario est idéal pour des applications critiques en arrière-plan, qui doivent fonctionner en continu avec une surveillance régulière et automatique pour garantir leur disponibilité.
