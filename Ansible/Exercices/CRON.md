# Exercices sur CRON

Voici une série de **20 exercices pratiques** accompagnés de solutions détaillées, illustrant des scénarios réels et progressifs pour utiliser efficacement `cron` dans la gestion des systèmes sous Linux. Chaque exercice inclut les étapes nécessaires pour la création de fichiers ou applications, afin que rien ne soit laissé à l'utilisateur.

---

### Niveau 1 : Débutant – Comprendre les bases de `cron`

#### **Exercice 1 : Vider la corbeille tous les lundis à 9h**

**Scénario :**  
Vous voulez automatiser le nettoyage de la corbeille de l'utilisateur pour libérer de l'espace disque chaque semaine.

**Solution :**

1. **Créer le script de nettoyage :**

```bash
nano ~/clean_trash.sh
```

2. **Ajouter le contenu suivant au script :**

```bash
#!/bin/bash
rm -rf ~/.local/share/Trash/*
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/clean_trash.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour exécuter le script tous les lundis à 9h :

```
0 9 * * 1 ~/clean_trash.sh
```

---

#### **Exercice 2 : Générer un rapport journalier de l'utilisation du disque**

**Scénario :**  
Un administrateur souhaite recevoir un rapport quotidien de l’utilisation de l’espace disque, enregistré dans un fichier.

**Solution :**

1. **Créer le script de rapport de disque :**

```bash
nano ~/disk_report.sh
```

2. **Ajouter le contenu suivant au script :**

```bash
#!/bin/bash
df -h > ~/disk_usage_report_$(date +\%F).log
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/disk_report.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour exécuter le script chaque jour à 6h du matin :

```
0 6 * * * ~/disk_report.sh
```

---

#### **Exercice 3 : Synchroniser l'horloge système avec un serveur NTP tous les jours à 2h**

**Scénario :**  
Pour garantir que votre système reste synchronisé, vous voulez synchroniser l’horloge du système avec un serveur NTP chaque jour à 2h du matin.

**Solution :**

1. **Installer `ntpdate` :**

```bash
sudo apt install ntpdate
```

2. **Créer le script de synchronisation :**

```bash
nano ~/sync_time.sh
```

3. **Ajouter le contenu suivant au script :**

```bash
#!/bin/bash
ntpdate pool.ntp.org
```

4. **Rendre le script exécutable :**

```bash
chmod +x ~/sync_time.sh
```

5. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour synchroniser l'horloge chaque jour à 2h du matin :

```
0 2 * * * ~/sync_time.sh
```

---

#### **Exercice 4 : Rotation des logs d'une application Python**

**Scénario :**  
Vous avez une application Python appelée `myapp` qui génère des logs. Vous souhaitez configurer une rotation automatique des logs tous les vendredis à minuit.

**Solution :**

1. **Créer l'application Python `myapp` :**

```bash
mkdir ~/myapp
nano ~/myapp/app.py
```

2. **Ajouter ce contenu au fichier `app.py` :**

```python
# /home/user/myapp/app.py
import time
import logging

# Configurer le logging
logging.basicConfig(filename='/home/user/myapp/myapp.log', level=logging.INFO)

while True:
    logging.info("L'application myapp tourne normalement.")
    time.sleep(60)
```

3. **Créer le script de rotation des logs :**

```bash
nano ~/rotate_logs.sh
```

4. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
# Archiver les logs
mv ~/myapp/myapp.log ~/myapp/logs/myapp_$(date +\%F).log
# Recréer un fichier de log vide
touch ~/myapp/myapp.log
```

5. **Rendre le script exécutable :**

```bash
chmod +x ~/rotate_logs.sh
```

6. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour exécuter le script chaque vendredi à minuit :

```
0 0 * * 5 ~/rotate_logs.sh
```

---

#### **Exercice 5 : Envoi automatique de la charge CPU toutes les heures**

**Scénario :**  
Vous souhaitez recevoir par e-mail un rapport de la charge CPU actuelle toutes les heures pour surveiller les performances du serveur.

**Solution :**

1. **Configurer l'envoi d'e-mails (via `mailutils`) :**

```bash
sudo apt install mailutils
```

2. **Créer le script pour obtenir la charge CPU :**

```bash
nano ~/send_cpu_report.sh
```

3. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
uptime | mail -s "Rapport CPU" admin@example.com
```

4. **Rendre le script exécutable :**

```bash
chmod +x ~/send_cpu_report.sh
```

5. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour exécuter le script chaque heure :

```
0 * * * * ~/send_cpu_report.sh
```

---

### Niveau 2 : Intermédiaire – Automatisation plus avancée avec `cron`

---

#### **Exercice 6 : Éteindre automatiquement un serveur non critique tous les soirs à 23h**

**Scénario :**  
Vous souhaitez arrêter un serveur de développement tous les soirs à 23h pour économiser de l'énergie.

**Solution :**

1. **Créer le script d'arrêt :**

```bash
nano ~/shutdown_server.sh
```

2. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
shutdown -h now
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/shutdown_server.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour éteindre le serveur chaque soir à 23h :

```
0 23 * * * ~/shutdown_server.sh
```

---

#### **Exercice 7 : Planifier une sauvegarde incrémentielle d'un répertoire critique chaque jour à 3h du matin**

**Scénario :**  
Vous souhaitez sauvegarder un répertoire critique (`/etc`) tous les jours à 3h du matin en effectuant des sauvegardes incrémentielles.

**Solution :**

1. **Créer le script de sauvegarde :**

```bash
nano ~/backup.sh
```

2. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
tar -czf ~/backups/etc_backup_$(date +\%F).tar.gz /etc
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/backup.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour exécuter la sauvegarde chaque jour à 3h du matin :

```
0 3 * * * ~/backup.sh
```

---

#### **Exercice 8 : Supprimer les fichiers temporaires vieux de plus de 7 jours chaque nuit**

**Scénario :**  
Pour éviter que les fichiers temporaires ne saturent l'espace disque, vous voulez supprimer tous les fichiers de `/tmp` vieux de plus de 7 jours.

**Solution :**

1. **Créer le script de suppression des fichiers temporaires :**

```bash
nano ~/clean_temp.sh
```

2. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
find /tmp -type f -mtime +7 -exec rm {} \;
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/clean_temp.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour exécuter le script chaque nuit à 2h du matin :

```
0 2 * * * ~/clean_temp.sh
```

---

#### **Exercice 9 : Redémarrer automatiquement un service (par exemple `nginx`) s'il s'arrête**

**Scénario :**  
Vous souhaitez surveiller un service essentiel, comme `nginx`, et redémarrer automatiquement ce service s'il s'arrête.

**Solution :**

1. **Créer le script de surveillance :**

```bash
nano ~/restart_nginx_if_down.sh
```

2. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
if ! systemctl is-active --quiet nginx; then
    systemctl start nginx
fi
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/restart_nginx_if_down.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la

 ligne suivante pour exécuter le script toutes les 5 minutes :

```
*/5 * * * * ~/restart_nginx_if_down.sh
```

---

#### **Exercice 10 : Planifier un scan antivirus hebdomadaire avec `ClamAV`**

**Scénario :**  
Vous souhaitez exécuter un scan antivirus hebdomadaire sur un serveur en utilisant `ClamAV`.

**Solution :**

1. **Installer ClamAV :**

```bash
sudo apt install clamav
```

2. **Créer le script de scan :**

```bash
nano ~/run_antivirus_scan.sh
```

3. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
clamscan -r /home/user/ > ~/antivirus_report_$(date +\%F).log
```

4. **Rendre le script exécutable :**

```bash
chmod +x ~/run_antivirus_scan.sh
```

5. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour exécuter le scan tous les dimanches à 3h du matin :

```
0 3 * * 0 ~/run_antivirus_scan.sh
```

---

### Niveau 3 : Avancé – Automatisation complexe avec `cron`

---

#### **Exercice 11 : Synchroniser des fichiers avec un serveur distant via `rsync` toutes les heures**

**Scénario :**  
Vous devez synchroniser un répertoire local avec un serveur distant via `rsync` toutes les heures.

**Solution :**

1. **Créer le script `rsync` :**

```bash
nano ~/sync_with_server.sh
```

2. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
rsync -avz /local_directory/ user@remote:/remote_directory/
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/sync_with_server.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour synchroniser les fichiers toutes les heures :

```
0 * * * * ~/sync_with_server.sh
```

---

#### **Exercice 12 : Créer un rapport de latence réseau avec `ping` chaque minute et l'analyser**

**Scénario :**  
Vous souhaitez surveiller la latence réseau en exécutant un `ping` toutes les minutes et enregistrer les résultats dans un fichier pour analyse.

**Solution :**

1. **Créer le script `ping` :**

```bash
nano ~/ping_google.sh
```

2. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
ping -c 4 google.com >> ~/ping_report.log
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/ping_google.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour exécuter le ping toutes les minutes :

```
* * * * * ~/ping_google.sh
```

---

#### **Exercice 13 : Générer un rapport d'utilisation de la RAM et le compresser chaque jour**

**Scénario :**  
Vous voulez générer un rapport d'utilisation de la RAM quotidiennement et compresser ce fichier pour l'archiver.

**Solution :**

1. **Créer le script de rapport de RAM :**

```bash
nano ~/memory_report.sh
```

2. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
free -h > ~/memory_usage_report_$(date +\%F).txt
gzip ~/memory_usage_report_$(date +\%F).txt
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/memory_report.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour générer le rapport et le compresser chaque jour à 2h :

```
0 2 * * * ~/memory_report.sh
```

---

#### **Exercice 14 : Redémarrer automatiquement une application après une mise à jour**

**Scénario :**  
Après une mise à jour de l'application `myapp`, vous devez redémarrer automatiquement le service lié.

**Solution :**

1. **Créer le script de redémarrage :**

```bash
nano ~/restart_myapp_after_update.sh
```

2. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
apt-get update && apt-get upgrade -y && systemctl restart myapp.service
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/restart_myapp_after_update.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour exécuter le script chaque jour à 1h du matin :

```
0 1 * * * ~/restart_myapp_after_update.sh
```

---

#### **Exercice 15 : Exécuter une tâche de maintenance de base de données tous les dimanches**

**Scénario :**  
Vous voulez exécuter un script qui optimise et nettoie votre base de données MySQL tous les dimanches à 4h du matin.

**Solution :**

1. **Créer le script de maintenance MySQL :**

```bash
nano ~/mysql_maintenance.sh
```

2. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
mysqlcheck -o --all-databases -u root -p'yourpassword'
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/mysql_maintenance.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour exécuter la maintenance chaque dimanche à 4h :

```
0 4 * * 0 ~/mysql_maintenance.sh
```

---

#### **Exercice 16 : Planifier la mise à jour de certificats SSL avec `certbot`**

**Scénario :**  
Vous devez renouveler les certificats SSL avec `certbot` chaque mois.

**Solution :**

1. **Créer le script de renouvellement SSL :**

```bash
nano ~/renew_ssl.sh
```

2. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
certbot renew --quiet
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/renew_ssl.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour renouveler les certificats tous les 1ers du mois à 1h :

```
0 1 1 * * ~/renew_ssl.sh
```

---

#### **Exercice 17 : Redémarrer un cluster Kubernetes chaque dimanche soir**

**Scénario :**  
Vous gérez un cluster Kubernetes et vous souhaitez le redémarrer chaque dimanche soir pour des raisons de maintenance.

**Solution :**

1. **Créer le script de redémarrage de Kubernetes :**

```bash
nano ~/restart_k8s.sh
```

2. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
kubectl rollout restart deployment --all
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/restart_k8s.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour redémarrer le cluster chaque dimanche à 23h :

```
0 23 * * 0 ~/restart_k8s.sh
```

---

#### **Exercice 18 : Planifier un redémarrage d'un service Docker tous les jours à 5h**

**Scénario :**  
Vous gérez des services Docker et vous souhaitez redémarrer un service Docker chaque jour à 5h.

**Solution :**

1. **Créer le script de redémarrage Docker :**

```bash
nano ~/restart_docker_service.sh
```

2. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
docker restart my_docker_service
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/restart_docker_service.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour redémarrer le service Docker chaque jour à 5h :

```
0 5 * * * ~/restart_docker_service.sh
```

---

#### **Exercice 19 : Planifier un nettoyage de disque à intervalles de 2 semaines**

**Scénario :**  
Vous souhaitez nettoyer un disque tous les 15 jours pour libérer de l'espace.

**Solution :**

1. **Créer le script de nettoyage :**

```bash
nano ~/clean_disk.sh
```

2. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
rm -rf /path/to/unwanted/files/*
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/clean_disk.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour exécuter le script tous les 15 jours à 3h :

```
0 3 */15 * * ~/clean_disk.sh
```

---

#### **Exercice 20 : Exécuter un script complexe qui combine plusieurs

 actions à minuit tous les jours**

**Scénario :**  
Vous devez exécuter un script complexe qui combine plusieurs tâches administratives comme la sauvegarde, la mise à jour du système et la rotation des logs chaque jour à minuit.

**Solution :**

1. **Créer le script :**

```bash
nano ~/complex_task.sh
```

2. **Ajouter ce contenu au script :**

```bash
#!/bin/bash
# 1. Sauvegarde
tar -czf ~/backups/full_backup_$(date +\%F).tar.gz /important/data

# 2. Mise à jour du système
apt-get update && apt-get upgrade -y

# 3. Rotation des logs
mv ~/logs/application.log ~/logs/application_$(date +\%F).log
touch ~/logs/application.log
```

3. **Rendre le script exécutable :**

```bash
chmod +x ~/complex_task.sh
```

4. **Configurer le cron job :**

```bash
crontab -e
```

Ajoutez la ligne suivante pour exécuter le script chaque jour à minuit :

```
0 0 * * * ~/complex_task.sh
```

---

### Conclusion

Ces **20 exercices pratiques** montrent comment utiliser `cron` pour automatiser des tâches de plus en plus complexes sous Linux. Chaque exercice est accompagné d'une solution complète, incluant la création des scripts nécessaires et leur intégration dans `cron`. Cela couvre des scénarios courants dans l'administration système et l'automatisation, offrant une base solide pour maîtriser `cron` dans un environnement de production.
