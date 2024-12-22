### Tutoriel : Établir une connexion SSH et installer Ansible pour un test avec le module `ping`

---

### **Objectif**
- Configurer une connexion SSH entre deux machines.
- Ajouter manuellement une clé publique à `authorized_keys`.
- Installer Ansible sur une machine serveur et tester la configuration avec le module `ping`.

---

### **Étape 1 : Préparer les deux machines**
1. **Machine cliente :**
   - Nom d'hôte : `client`
   - IP : `192.168.1.100`

2. **Machine serveur :**
   - Nom d'hôte : `server`
   - IP : `192.168.1.101`

---

### **Étape 2 : Générer une paire de clés SSH sur la machine cliente**
1. Connectez-vous à la machine cliente.
2. Générez une paire de clés SSH :
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
   ```
   - Appuyez sur **Entrée** pour accepter les valeurs par défaut.
   - Une clé publique sera générée dans `~/.ssh/id_rsa.pub`.

---

### **Étape 3 : Copier la clé publique sur la machine serveur (manuellement)**
1. Connectez-vous à la machine serveur.
2. Créez le répertoire `.ssh` dans le répertoire personnel de l'utilisateur cible (par exemple `ansadmin`) :
   ```bash
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   ```
3. Depuis la machine cliente, affichez le contenu de la clé publique :
   ```bash
   cat ~/.ssh/id_rsa.pub
   ```
4. Copiez le contenu de `id_rsa.pub` et ajoutez-le manuellement au fichier `authorized_keys` sur la machine serveur :
   ```bash
   nano ~/.ssh/authorized_keys
   ```
   - Collez la clé publique.
   - Sauvegardez et fermez le fichier.
5. Configurez les permissions sur le fichier et le dossier :
   ```bash
   chmod 600 ~/.ssh/authorized_keys
   chmod 700 ~/.ssh
   ```

---

### **Étape 4 : Tester la connexion SSH**
1. Depuis la machine cliente, testez la connexion SSH vers le serveur :
   ```bash
   ssh ansadmin@192.168.1.101
   ```
   - Si la configuration est correcte, vous serez connecté sans demander de mot de passe.

---

### **Étape 5 : Installer Ansible sur la machine serveur**
1. Connectez-vous à la machine serveur.
2. Mettez à jour le système :
   ```bash
   sudo apt update && sudo apt upgrade -y   # Pour Ubuntu/Debian
   sudo zypper refresh && sudo zypper update -y   # Pour openSUSE
   sudo yum update -y   # Pour CentOS/RHEL
   ```
3. Installez Ansible :
   ```bash
   sudo apt install ansible -y   # Pour Ubuntu/Debian
   sudo zypper install ansible -y   # Pour openSUSE
   sudo yum install ansible -y   # Pour CentOS/RHEL
   ```

---

### **Étape 6 : Configurer Ansible**
1. Sur la machine serveur, créez un fichier d'inventaire pour définir les hôtes :
   ```bash
   sudo nano /etc/ansible/hosts
   ```
2. Ajoutez l’IP de la machine cliente sous un groupe `[clients]` :
   ```text
   [clients]
   192.168.1.100
   ```
3. Sauvegardez et fermez le fichier.

---

### **Étape 7 : Tester avec le module `ping`**
1. Sur la machine serveur, utilisez le module `ping` pour tester la connectivité Ansible :
   ```bash
   ansible -m ping all
   ```
2. Vous devriez obtenir une sortie similaire à :
   ```text
   192.168.1.100 | SUCCESS => {
       "changed": false,
       "ping": "pong"
   }
   ```

---

### **Résolution des problèmes possibles**
- **Erreur de permission sur `authorized_keys`** :
  - Vérifiez que les permissions du fichier et du dossier sont correctes.
- **Problème de pare-feu** :
  - Autorisez les connexions SSH sur le port 22 :
    ```bash
    sudo ufw allow ssh    # Pour Ubuntu/Debian
    sudo firewall-cmd --add-service=ssh --permanent && sudo firewall-cmd --reload   # Pour CentOS/RHEL
    ```

---

Ce tutoriel vous permettra d'établir une connexion SSH entre deux machines, d'installer Ansible et de tester la configuration avec le module `ping`.
