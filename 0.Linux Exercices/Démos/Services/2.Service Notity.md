# Le service Notify

### Scénario : Création d'un service `notify` avec systemd pour une application Python simulant un service long à démarrer

Dans ce scénario, nous allons configurer un service `systemd` de type `notify`. Ce type de service est utilisé lorsque l'application/service notifie explicitement `systemd` qu'il est prêt, plutôt que d'être considéré comme prêt immédiatement après le lancement. Cela est particulièrement utile pour les services qui nécessitent un certain temps pour démarrer, comme des serveurs d'applications complexes ou des services dépendant d'autres ressources.

Nous allons :

1. Créer une application Python simulant un service prenant du temps à démarrer.
2. Configurer un service `systemd` de type `notify`.
3. Mettre en place une notification à `systemd` une fois que l'application est réellement prête.

### Objectif

- **Application Python** : Un script Python qui simule un service nécessitant du temps pour être prêt.
- **Type de service `notify`** : Utiliser la bibliothèque `sdnotify` pour notifier `systemd` lorsque l'application est prête.
- **Service `systemd`** : Un service de type `notify` qui ne sera considéré comme actif qu'une fois la notification envoyée.

### Étapes

---

### **1. Créer une application Python simulant un service long à démarrer**

Nous allons créer une application Python qui attend 10 secondes avant de notifier qu'elle est prête, en utilisant la bibliothèque `sdnotify`.

#### a. **Installer la bibliothèque `sdnotify`**

La bibliothèque `sdnotify` permet aux applications de notifier `systemd` de leur état. Installez-la avec `pip` :

```bash
sudo pip3 install sdnotify
```

#### b. **Écrire l'application Python**

Créez un répertoire pour l'application Python :

```bash
mkdir /usr/local/bin/myapp_notify
cd /usr/local/bin/myapp_notify
```

Créez un fichier `app_notify.py` :

```python
import time
from sdnotify import SystemdNotifier

# Créer une instance du notifier systemd
notifier = SystemdNotifier()

print("Démarrage de l'application, préparation en cours...")
time.sleep(10)  # Simule une tâche longue (ex : initialisation du service)

# Notifier systemd que le service est prêt
notifier.notify("READY=1")
print("Application prête, notification envoyée à systemd")

# Continuer l'exécution normale du service (par exemple, un serveur en arrière-plan)
while True:
    notifier.notify("WATCHDOG=1")  # Notifie systemd périodiquement que le service est toujours actif
    time.sleep(5)
```

Ce script Python simule une tâche qui prend 10 secondes à se préparer, puis notifie `systemd` que le service est prêt. Le script continue ensuite à tourner en envoyant une notification périodique (`WATCHDOG=1`) pour indiquer qu'il est toujours en vie.

#### c. **Tester le script**

Exécutez le script pour vérifier son fonctionnement :

```bash
python3 /usr/local/bin/myapp_notify/app_notify.py
```

Vous devriez voir des messages indiquant que l'application démarre, attend 10 secondes, puis notifie qu'elle est prête.

---

### **2. Configurer un service `systemd` de type `notify`**

Nous allons maintenant configurer `systemd` pour gérer ce service Python avec le type de service `notify`.

#### a. **Créer le fichier de service `systemd`**

Créez un fichier de service dans `/etc/systemd/system/myapp_notify.service` :

```bash
sudo nano /etc/systemd/system/myapp_notify.service
```

Ajoutez le contenu suivant :

```ini
[Unit]
Description=MyApp Notify Service
After=network.target  # Lancer après que le réseau soit prêt

[Service]
Type=notify  # Le service ne sera considéré comme prêt qu'après la notification READY=1
ExecStart=/usr/bin/python3 /usr/local/bin/myapp_notify/app_notify.py
NotifyAccess=all  # Permet à tous les processus du service de notifier systemd
User=<user>  # Remplacez par l'utilisateur qui exécute le service
Restart=on-failure  # Redémarre automatiquement en cas d'échec
WatchdogSec=15  # Intervalle pour les notifications WATCHDOG

[Install]
WantedBy=multi-user.target
```

- **Type=notify** : Le service n’est pas considéré comme démarré tant qu’il n’a pas envoyé la notification `READY=1`.
- **NotifyAccess=all** : Permet à tous les processus de notifier `systemd`.
- **WatchdogSec=15** : Le service doit envoyer une notification WATCHDOG toutes les 15 secondes, sinon il sera redémarré.

#### b. **Activer et démarrer le service**

Rechargez `systemd` pour prendre en compte le nouveau service :

```bash
sudo systemctl daemon-reload
```

Activez le service pour qu'il démarre au démarrage du système :

```bash
sudo systemctl enable myapp_notify.service
```

Démarrez le service :

```bash
sudo systemctl start myapp_notify.service
```

#### c. **Vérifier le statut du service**

Vérifiez que le service fonctionne correctement et qu'il a bien envoyé la notification à `systemd` :

```bash
sudo systemctl status myapp_notify.service
```

Vous devriez voir que le service est marqué comme **active (running)** après les 10 secondes initiales, correspondant au délai simulé par le script avant d'envoyer `READY=1`.

---

### **3. Ajouter un timer ou un redémarrage automatique**

Si vous souhaitez vérifier régulièrement le bon fonctionnement de l'application ou automatiser son redémarrage en cas d'échec, `systemd` s'en occupera avec les options déjà incluses (`Restart=on-failure`). Vous n'avez pas besoin d'un timer supplémentaire, car `systemd` se charge de la supervision à travers les notifications envoyées par `WATCHDOG=1`.

Si le service cesse d'envoyer cette notification dans le délai défini (ici 15 secondes), `systemd` redémarrera automatiquement le service.

---

### Conclusion

Dans ce scénario, vous avez appris à :

1. **Créer une application Python** qui envoie des notifications à `systemd` lorsqu'elle est prête à être utilisée et qu'elle est toujours en bonne santé.
2. **Configurer un service `notify` avec `systemd`**, un type de service particulièrement utile pour les applications qui nécessitent un temps de démarrage ou une initialisation avant d'être prêtes.
3. **Mettre en place des notifications WATCHDOG** pour que `systemd` puisse surveiller et redémarrer l'application si elle cesse de fonctionner correctement.

Ce type de configuration est essentiel pour les services complexes, comme des serveurs web, des bases de données, ou des applications ayant des dépendances réseau, où vous ne voulez pas que le service soit considéré comme "prêt" avant qu'il ne le soit vraiment.
