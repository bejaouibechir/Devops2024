#  **Labo 2 — Containerisation Docker (PHP + MySQL)**

##  **Objectif**

Déployer la même application PHP sous forme de **deux conteneurs distincts** :

* Un conteneur **backend PHP + Apache**
* Un conteneur **MySQL**

→ Les relier ensemble via `--link`.

---

#  **Démarche structurée**

##  ** Préparer les fichiers localement**

###  Structure proposée

```
project/
│
├── backend/
│   ├── Dockerfile
│   └── src/          # Contient tous tes fichiers PHP
│       ├── index.php
│       ├── create.php
│       ├── ...
│       └── config.php
│
├── mysql/
│   ├── Dockerfile
│   └── script.sql
```

---

## ** Créer le Dockerfile backend**

**`project/backend/Dockerfile`** :

```dockerfile
FROM php:apache

# Installer mysqli
RUN docker-php-ext-install mysqli

# Activer mod_rewrite (optionnel si besoin)
RUN a2enmod rewrite

# Copier le code PHP
COPY src/ /var/www/html/

# Droits fichiers (optionnel si problème de droits)
RUN chown -R www-data:www-data /var/www/html/

EXPOSE 80
```

---

## ** Adapter `config.php`**

Dans ton dossier `src/`, mets :

```php
define('DB_SERVER', 'mysql');
define('DB_USERNAME', 'test');
define('DB_PASSWORD', 'test123++');
define('DB_NAME', 'businessdb');
```

>  Important : `DB_SERVER = 'mysql'` car tu vas utiliser `--link` (alias `mysql`).

---

## ** Créer le Dockerfile MySQL**

**`project/mysql/Dockerfile`** :

```dockerfile
FROM mysql

ENV MYSQL_ROOT_PASSWORD=test123++
ENV MYSQL_DATABASE=businessdb
ENV MYSQL_USER=test
ENV MYSQL_PASSWORD=test123++

COPY script.sql /docker-entrypoint-initdb.d/
```

---

## ** Construire les images**

Dans le dossier `project/backend` :

```bash
docker build -t php-app-image .
```

Dans le dossier `project/mysql` :

```bash
docker build -t mysql-app-image .
```

---

##  ** Créer et démarrer les conteneurs**

### Démarrer MySQL

```bash
docker run -d --name mysql-container -p 3308:3306 -v mysql_data:/var/lib/mysql mysql-app-image
```

### Démarrer PHP + Apache

```bash
docker run -d --name php-container --link mysql-container:mysql -p 8080:80 php-app-image
```

---

##  ** Accéder à l'application**

Dans ton navigateur :

```
http://<IP_PUBLIC>:8080
```

---

##  ** Vérifier le fonctionnement**

*  Liste d’employés affichée (vide si pas de données).
*  Opérations CRUD fonctionnelles (création, lecture, mise à jour, suppression).
*  Pas d’erreurs PHP ou MySQL.

---

#  **Résumé des commandes clés**

```bash
# Build backend
cd project/backend
docker build -t php-app-image .

# Build MySQL
cd ../mysql
docker build -t mysql-app-image .

# Run MySQL
docker run -d --name mysql-container -p 3308:3306 -v mysql_data:/var/lib/mysql mysql-app-image

# Run PHP
docker run -d --name php-container --link mysql-container:mysql -p 8080:80 php-app-image
```

---

##  **Points à surveiller**

* Bien ouvrir le port **8080** dans le groupe de sécurité AWS.
* Ne pas oublier d’utiliser le bon mot de passe MySQL dans `config.php`.
* Vérifier que le volume MySQL fonctionne si tu veux garder les données.

---

#  **Conclusion**

 Avec cette démarche, ton projet est maintenant **100 % containerisé**, tout en restant simple et pédagogique pour un labo d'initiation DevOps.


