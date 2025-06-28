#  **Labo 1 — Déploiement classique (sans container)**

##  **Objectif**

Déployer une application PHP connectée à MySQL sur une instance EC2 Ubuntu, sans containerisation.
L’application permet de gérer des employés (CRUD).

---

##  **Préparation de la machine EC2**

###  Lancer une instance EC2

* Type d’instance : t3.micro ou supérieure (1 ou 2 vCPU, 1–8 Go RAM)
* OS : Ubuntu 22.04
* Sécurité : ouvrir les ports

  * **22** (SSH)
  * **80** (HTTP)
  * **443** (optionnel pour HTTPS)

---

##  **Connexion à l'instance**

```bash
ssh -i "votre_clef.pem" ubuntu@<IP_PUBLIC>
```

---

## ⚙ **Mise à jour du système**

```bash
sudo apt update && sudo apt upgrade -y
```

---

##  **Installation de la stack web (Apache, PHP, MySQL)**

###  Installer Apache et PHP

```bash
sudo apt install apache2 php libapache2-mod-php php-mysqli -y
```

###  Installer MySQL

```bash
sudo apt install mysql-server -y
```

---

##  **Sécuriser et configurer MySQL**

###  Lancer la configuration sécurisée (optionnel)

```bash
sudo mysql_secure_installation
```

###  Modifier l’utilisateur root pour activer l’authentification par mot de passe

```bash
sudo mysql
```

```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'TonMotDePasse';
FLUSH PRIVILEGES;
exit;
```

---

##  **Création de la base et de la table**

###  Créer un fichier `script.sql` localement

```sql
CREATE DATABASE IF NOT EXISTS businessdb;
USE businessdb;

CREATE TABLE IF NOT EXISTS employees (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    salary INT NOT NULL
);
```

---

###  Envoyer le fichier sur l’EC2

```bash
scp -i "votre_clef.pem" script.sql ubuntu@<IP_PUBLIC>:/tmp/
```

---

###  Exécuter le script

```bash
mysql -u root -p < /tmp/script.sql
```

---

##  **Déploiement de l'application PHP**

###  Envoyer les fichiers PHP

```bash
scp -i "votre_clef.pem" *.php ubuntu@<IP_PUBLIC>:/tmp/
```

---

###  Déplacer les fichiers dans Apache

```bash
sudo mv /tmp/*.php /var/www/html/
```

---

###  Supprimer la page par défaut Apache

```bash
sudo rm /var/www/html/index.html
```

---

###  Vérifier les permissions

```bash
sudo chown www-data:www-data /var/www/html/*.php
sudo chmod 644 /var/www/html/*.php
```

---

###  Adapter `config.php`

```php
define('DB_SERVER', 'localhost');
define('DB_USERNAME', 'root');
define('DB_PASSWORD', 'TonMotDePasse');
define('DB_NAME', 'businessdb');
```

---

###  Redémarrer Apache

```bash
sudo systemctl restart apache2
```

---

##  **Accès à l'application**

* Ouvrir ton navigateur
* URL : `http://<IP_PUBLIC>`

---

##  **Vérifications finales**

*  Page d’accueil visible (liste des employés)
*  Ajouter, consulter, modifier, supprimer des employés fonctionne
*  Pas d’erreurs PHP ou MySQL

---

## **Résultat**

 Application PHP 100 % fonctionnelle, déployée classiquement sur Apache et MySQL sur une instance EC2.

---

# 🧭 **Résumé visuel (workflow)**

```
[EC2 Ubuntu]
    ├─ Apache + PHP installés
    ├─ MySQL installé et configuré
    ├─ Base businessdb créée
    ├─ Tables créées
    ├─ Fichiers PHP copiés
    └─ Application accessible via navigateur
```

