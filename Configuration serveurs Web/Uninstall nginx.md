# **Procédure complète pour la désinstallation et la purge de Nginx sur Ubuntu**

### **1. Arrêter et désactiver Nginx**

1. **Arrêtez le service Nginx** :
   ```bash
   sudo systemctl stop nginx
   ```

2. **Désactivez le démarrage automatique au boot** :
   ```bash
   sudo systemctl disable nginx
   ```

3. **Vérifiez que le service est bien arrêté** :
   ```bash
   sudo systemctl status nginx
   ```

---

### **2. Désinstaller Nginx**

#### **2.1 Supprimer le package Nginx**
1. Désinstallez Nginx et ses dépendances :
   ```bash
   sudo apt remove --purge nginx nginx-common
   ```

2. Nettoyez les dépendances inutiles :
   ```bash
   sudo apt autoremove
   ```

3. Supprimez le cache des paquets téléchargés :
   ```bash
   sudo apt clean
   ```

---

### **3. Supprimer les fichiers de configuration restants**

1. Supprimez le répertoire de configuration (facultatif) :
   ```bash
   sudo rm -rf /etc/nginx
   ```

2. Supprimez les journaux de Nginx :
   ```bash
   sudo rm -rf /var/log/nginx
   ```

3. Supprimez les répertoires associés (parfois créés manuellement) :
   ```bash
   sudo rm -rf /var/www/html
   ```

---

### **4. Vérifier que Nginx est complètement supprimé**

1. **Vérifiez que le binaire Nginx n’existe plus** :
   ```bash
   which nginx
   ```

2. **Vérifiez que le port 80 ou 443 n'est plus utilisé** :
   ```bash
   sudo netstat -tuln | grep 80
   ```

3. **Assurez-vous qu'aucun processus Nginx ne tourne** :
   ```bash
   ps aux | grep nginx
   ```

---

### **5. Étapes supplémentaires (facultatif)**

#### **5.1 Supprimer des sites personnalisés**
Si vous avez créé des sites dans `/etc/nginx/sites-available` ou `/etc/nginx/sites-enabled`, supprimez-les également :
```bash
sudo rm -rf /etc/nginx/sites-available/*
sudo rm -rf /etc/nginx/sites-enabled/*
```

#### **5.2 Supprimer les fichiers SSL (s'ils existent)**
Si vous avez configuré des certificats SSL pour Nginx, supprimez-les :
```bash
sudo rm -rf /etc/ssl/certs/nginx*
sudo rm -rf /etc/ssl/private/nginx*
```

---

### **Résumé des commandes principales**

```bash
# 1. Arrêter et désactiver Nginx
sudo systemctl stop nginx
sudo systemctl disable nginx

# 2. Désinstaller Nginx
sudo apt remove --purge nginx nginx-common
sudo apt autoremove
sudo apt clean

# 3. Supprimer les fichiers associés
sudo rm -rf /etc/nginx
sudo rm -rf /var/log/nginx
sudo rm -rf /var/www/html

# 4. Vérifier les ports et les processus
sudo netstat -tuln | grep 80
ps aux | grep nginx
```

---

### **Vérification post-désinstallation**
Une fois toutes les étapes terminées, relancez une vérification rapide :
- **Commande pour vérifier l’absence de Nginx** :
  ```bash
  nginx -v
  ```
  Si cela renvoie une erreur (`command not found`), cela signifie que Nginx a été complètement désinstallé.
