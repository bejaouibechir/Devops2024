# **Procédure complète pour la désinstallation et la purge de Tomcat sur Ubuntu**

### **1. Arrêter le service Tomcat**
Avant de procéder à la désinstallation, il est important de stopper Tomcat si celui-ci est en cours d’exécution.

1. **Si Tomcat a été installé avec un script de service systemd** :
   ```bash
   sudo systemctl stop tomcat
   sudo systemctl disable tomcat
   ```

2. **Si Tomcat a été démarré manuellement avec le script `startup.sh`** :
   - Localisez et arrêtez le processus Tomcat :
     ```bash
     ps aux | grep tomcat
     ```
   - Tuez le processus :
     ```bash
     sudo kill -9 <PID>
     ```

---

### **2. Supprimer les fichiers de Tomcat**
1. **Localisez le répertoire d’installation de Tomcat** (par défaut, il est dans `/opt/tomcat`) :
   ```bash
   sudo rm -rf /opt/tomcat
   ```

2. **Supprimez les fichiers de configuration restants (facultatif)** :
   Si vous avez créé des fichiers personnalisés, comme un service systemd, supprimez-les :
   - Fichier de service :
     ```bash
     sudo rm -f /etc/systemd/system/tomcat.service
     ```

   - Vérifiez que le service n'existe plus :
     ```bash
     sudo systemctl daemon-reload
     sudo systemctl list-units --type=service | grep tomcat
     ```

3. **Supprimez les journaux associés** (facultatif) :
   Si des journaux spécifiques ont été générés ailleurs, supprimez-les :
   ```bash
   sudo rm -rf /var/log/tomcat*
   ```

---

### **3. Supprimer les utilisateurs ou groupes dédiés (facultatif)**
Si vous avez créé un utilisateur ou un groupe dédié à Tomcat :
1. **Supprimez l’utilisateur Tomcat** :
   ```bash
   sudo deluser --remove-home tomcat
   ```

2. **Supprimez le groupe Tomcat** :
   ```bash
   sudo delgroup tomcat
   ```

---

### **4. Vérifier la désinstallation complète**
1. **Vérifiez que le répertoire de Tomcat a été supprimé** :
   ```bash
   ls /opt | grep tomcat
   ```

2. **Vérifiez que Tomcat ne tourne plus** :
   ```bash
   ps aux | grep tomcat
   ```

3. **Vérifiez les ports utilisés** :
   Si vous aviez changé le port d'écoute, assurez-vous que le port n’est plus utilisé :
   ```bash
   sudo netstat -tuln | grep <PORT>
   ```

---

### **5. Étapes supplémentaires (facultatif)**
1. **Si Tomcat a été installé via un gestionnaire de paquets (rare)** :
   Supprimez-le avec `apt` :
   ```bash
   sudo apt remove --purge tomcat*
   sudo apt autoremove
   ```

2. **Nettoyez le cache de `apt`** :
   ```bash
   sudo apt clean
   ```

---

### **Résumé des commandes principales**
```bash
# 1. Arrêter Tomcat
sudo systemctl stop tomcat
sudo systemctl disable tomcat

# 2. Supprimer le répertoire d'installation
sudo rm -rf /opt/tomcat

# 3. Supprimer le service systemd
sudo rm -f /etc/systemd/system/tomcat.service
sudo systemctl daemon-reload

# 4. Supprimer les journaux
sudo rm -rf /var/log/tomcat*

# 5. (Facultatif) Supprimer utilisateur/groupe Tomcat
sudo deluser --remove-home tomcat
sudo delgroup tomcat
```
