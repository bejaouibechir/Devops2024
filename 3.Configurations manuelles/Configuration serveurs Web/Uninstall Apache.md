# **Procédure complète pour la désinstallation et la purge d'Apache sur Ubuntu**

### **1. Arrêter et désactiver Apache**

1. **Arrêtez le service Apache** :
   ```bash
   sudo systemctl stop apache2
   ```

2. **Désactivez le démarrage automatique au boot** :
   ```bash
   sudo systemctl disable apache2
   ```

3. **Vérifiez que le service est bien arrêté** :
   ```bash
   sudo systemctl status apache2
   ```

---

### **2. Désinstaller Apache**

1. **Supprimez Apache et ses dépendances** :
   ```bash
   sudo apt remove --purge apache2 apache2-utils apache2-bin apache2.2-common
   ```

2. **Nettoyez les dépendances inutiles** :
   ```bash
   sudo apt autoremove
   ```

3. **Nettoyez le cache des paquets téléchargés** :
   ```bash
   sudo apt clean
   ```

---

### **3. Supprimer les fichiers de configuration restants**

1. **Supprimez le répertoire de configuration (facultatif)** :
   ```bash
   sudo rm -rf /etc/apache2
   ```

2. **Supprimez les journaux d'Apache** :
   ```bash
   sudo rm -rf /var/log/apache2
   ```

3. **Supprimez les répertoires associés (parfois créés manuellement)** :
   ```bash
   sudo rm -rf /var/www/html
   ```

---

### **4. Vérifier que Apache est complètement supprimé**

1. **Vérifiez que le binaire Apache n’existe plus** :
   ```bash
   which apache2
   ```

2. **Vérifiez que le port 80 ou 443 n'est plus utilisé** :
   ```bash
   sudo netstat -tuln | grep 80
   ```

3. **Assurez-vous qu'aucun processus Apache ne tourne** :
   ```bash
   ps aux | grep apache
   ```

---

### **5. Étapes supplémentaires (facultatif)**

#### **5.1 Supprimer des sites personnalisés**
Si vous avez créé des sites dans `/etc/apache2/sites-available` ou `/etc/apache2/sites-enabled`, supprimez-les également :
```bash
sudo rm -rf /etc/apache2/sites-available/*
sudo rm -rf /etc/apache2/sites-enabled/*
```

#### **5.2 Supprimer les fichiers SSL (s'ils existent)**
Si vous avez configuré des certificats SSL pour Apache, supprimez-les :
```bash
sudo rm -rf /etc/ssl/certs/apache*
sudo rm -rf /etc/ssl/private/apache*
```

---

### **Résumé des commandes principales**

```bash
# 1. Arrêter et désactiver Apache
sudo systemctl stop apache2
sudo systemctl disable apache2

# 2. Désinstaller Apache
sudo apt remove --purge apache2 apache2-utils apache2-bin apache2.2-common
sudo apt autoremove
sudo apt clean

# 3. Supprimer les fichiers associés
sudo rm -rf /etc/apache2
sudo rm -rf /var/log/apache2
sudo rm -rf /var/www/html

# 4. Vérifier les ports et les processus
sudo netstat -tuln | grep 80
ps aux | grep apache
```

---

### **Vérification post-désinstallation**

1. **Vérifiez que Apache est bien désinstallé** :
   ```bash
   apache2 -v
   ```
   Si cette commande renvoie une erreur (`command not found`), Apache a été complètement supprimé.

2. **Vérifiez que les ports utilisés par Apache sont libérés** :
   ```bash
   sudo netstat -tuln | grep 80
   ```

---

### **Conclusion**

Vous avez maintenant désinstallé Apache complètement. Les fichiers associés, les configurations, et les journaux ont été supprimés. 
