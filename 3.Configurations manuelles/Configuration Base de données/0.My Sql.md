## **Tutoriel : Installation et Configuration de MySQL avec Démos**

### **1. Installation de MySQL**

#### **1.1 Installer MySQL**
1. **Mettez à jour les paquets** :
   ```bash
   sudo apt update
   ```

2. **Installez le serveur MySQL** :
   ```bash
   sudo apt install -y mysql-server
   ```

3. **Vérifiez la version installée** :
   ```bash
   mysql --version
   ```

4. **Démarrez le service MySQL** :
   ```bash
   sudo systemctl start mysql
   ```

5. **Activez MySQL au démarrage** :
   ```bash
   sudo systemctl enable mysql
   ```

6. **Vérifiez l'état du service** :
   ```bash
   sudo systemctl status mysql
   ```

---

### **2. Configuration initiale**

#### **2.1 Sécuriser l'installation de MySQL**
1. Exécutez l'assistant de sécurisation :
   ```bash
   sudo mysql_secure_installation
   ```

2. Les étapes incluent :
   - Définir un mot de passe pour l'utilisateur root.
   - Supprimer les utilisateurs anonymes.
   - Désactiver les connexions root à distance.
   - Supprimer la base de données de test.

---

#### **2.2 Se connecter à MySQL avec la CLI**
1. Connectez-vous à MySQL avec l'utilisateur root :
   ```bash
   sudo mysql -u root -p
   ```

2. Une fois connecté, vous verrez un prompt MySQL (`mysql>`). Vous êtes prêt à exécuter des commandes.

---

### **3. Démos pratiques avec MySQL CLI**

#### **3.1 Créer une base de données et un utilisateur**
1. **Créer une base de données** :
   ```sql
   CREATE DATABASE test_db;
   ```

2. **Créer un utilisateur avec un mot de passe** :
   ```sql
   CREATE USER 'test_user'@'localhost' IDENTIFIED BY 'password123';
   ```

3. **Donner des permissions à l'utilisateur sur la base de données** :
   ```sql
   GRANT ALL PRIVILEGES ON test_db.* TO 'test_user'@'localhost';
   FLUSH PRIVILEGES;
   ```

4. **Vérifier les bases de données disponibles** :
   ```sql
   SHOW DATABASES;
   ```

---

#### **3.2 Insérer des données et exécuter une requête simple**
1. **Utiliser la base de données** :
   ```sql
   USE test_db;
   ```

2. **Créer une table** :
   ```sql
   CREATE TABLE students (
       id INT AUTO_INCREMENT PRIMARY KEY,
       name VARCHAR(100),
       age INT
   );
   ```

3. **Insérer des données** :
   ```sql
   INSERT INTO students (name, age) VALUES ('Alice', 22), ('Bob', 25);
   ```

4. **Lire les données** :
   ```sql
   SELECT * FROM students;
   ```

---

### **4. Modifier le port d'écoute de MySQL**

1. **Modifier le fichier de configuration principal** :
   ```bash
   sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
   ```

2. **Recherchez la directive `port`** et remplacez-la (par exemple, changez `3306` en `3307`) :
   ```ini
   port = 3307
   ```

3. **Redémarrez MySQL pour appliquer les changements** :
   ```bash
   sudo systemctl restart mysql
   ```

4. **Vérifiez que MySQL écoute sur le nouveau port** :
   ```bash
   sudo netstat -tuln | grep 3307
   ```

5. **Se connecter au nouveau port** :
   ```bash
   mysql -u root -p --port=3307
   ```

---

### **5. Gestion et journalisation**

#### **5.1 Fichiers de logs**
1. **Vérifiez les journaux d'erreurs de MySQL** :
   ```bash
   sudo tail -f /var/log/mysql/error.log
   ```

2. **Rechercher une erreur spécifique dans les journaux** :
   ```bash
   sudo grep "error" /var/log/mysql/error.log
   ```

---

#### **5.2 Gérer MySQL avec systemd**
1. **Démarrer MySQL** :
   ```bash
   sudo systemctl start mysql
   ```

2. **Arrêter MySQL** :
   ```bash
   sudo systemctl stop mysql
   ```

3. **Redémarrer MySQL** :
   ```bash
   sudo systemctl restart mysql
   ```

4. **Vérifier l’état de MySQL** :
   ```bash
   sudo systemctl status mysql
   ```

---

### **6. Dépannage**

1. **Si MySQL ne démarre pas, vérifiez les journaux d'erreurs** :
   ```bash
   sudo tail -f /var/log/mysql/error.log
   ```

2. **Vérifiez les ports occupés** :
   ```bash
   sudo netstat -tuln | grep 3306
   ```

3. **Tuer le processus utilisant le port** :
   ```bash
   sudo kill -9 <PID>
   ```

4. **Vérifiez la configuration MySQL** :
   ```bash
   sudo mysqladmin ping -u root -p
   ```

---

### **Résumé des commandes principales**

#### **Installation et Configuration**
```bash
# Installation
sudo apt update
sudo apt install -y mysql-server

# Démarrage et activation
sudo systemctl start mysql
sudo systemctl enable mysql
sudo mysql_secure_installation
```

#### **Commandes MySQL CLI**
```sql
# Connexion
sudo mysql -u root -p

# Création d'une base et utilisateur
CREATE DATABASE test_db;
CREATE USER 'test_user'@'localhost' IDENTIFIED BY 'password123';
GRANT ALL PRIVILEGES ON test_db.* TO 'test_user'@'localhost';
FLUSH PRIVILEGES;

# Gestion des données
USE test_db;
CREATE TABLE students (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100), age INT);
INSERT INTO students (name, age) VALUES ('Alice', 22), ('Bob', 25);
SELECT * FROM students;
```

#### **Changement du port**
```bash
# Modifier la configuration
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
# Modifier "port = 3306" en "port = 3307"
sudo systemctl restart mysql
```
