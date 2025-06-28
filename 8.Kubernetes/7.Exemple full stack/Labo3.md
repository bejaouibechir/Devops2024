#  **Labo 3 — Déploiement avec Docker Compose**

##  **Objectif**

Déployer la même application PHP + MySQL, mais cette fois en utilisant **Docker Compose** pour simplifier et orchestrer les conteneurs.

---

#  **Démarche structurée**

##  ** Préparer la structure du projet**

Voici une structure claire :

```
project/
│
├── backend/
│   ├── Dockerfile
│   └── src/
│       ├── index.php
│       ├── create.php
│       ├── ...
│       └── config.php
│
├── mysql/
│   ├── Dockerfile
│   └── script.sql
│
└── docker-compose.yml
```

---

##  ** Adapter le Dockerfile backend**

**`backend/Dockerfile`** :

```dockerfile
FROM php:apache

RUN docker-php-ext-install mysqli
RUN a2enmod rewrite

COPY src/ /var/www/html/
RUN chown -R www-data:www-data /var/www/html/

EXPOSE 80
```

---

##  ** Adapter `config.php`**

Dans `src/config.php` :

```php
define('DB_SERVER', 'db');
define('DB_USERNAME', 'test');
define('DB_PASSWORD', 'test123++');
define('DB_NAME', 'businessdb');
```

> ✅ Ici, `DB_SERVER = 'db'` correspond au nom de service MySQL défini dans `docker-compose.yml`.

---

## ** Adapter le Dockerfile MySQL**

**`mysql/Dockerfile`** :

```dockerfile
FROM mysql

ENV MYSQL_ROOT_PASSWORD=test123++
ENV MYSQL_DATABASE=businessdb
ENV MYSQL_USER=test
ENV MYSQL_PASSWORD=test123++

COPY script.sql /docker-entrypoint-initdb.d/
```

---

##  ** Créer le fichier `docker-compose.yml`**

**`docker-compose.yml`** :

```yaml
version: '3.8'

services:
  db:
    build: ./mysql
    container_name: mysql-container
    ports:
      - "3308:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: test123++
      MYSQL_DATABASE: businessdb
      MYSQL_USER: test
      MYSQL_PASSWORD: test123++

  web:
    build: ./backend
    container_name: php-container
    ports:
      - "8080:80"
    depends_on:
      - db

volumes:
  mysql_data:
```

---

##  ** Construire et démarrer l'application**

Depuis le dossier `project` :

```bash
docker-compose up --build -d
```

---

##  ** Vérifier les conteneurs**

```bash
docker ps
```

 Tu dois voir `php-container` et `mysql-container` en cours d’exécution.

---

##  ** Accéder à l'application**

Dans ton navigateur :

```
http://<IP_PUBLIC>:8080
```

---

# ** Vérifier le fonctionnement**

*  Page d’accueil s’affiche.
*  CRUD complet fonctionnel.
*  Base persistée grâce au volume.

---

#  **Résumé rapide (workflow)**

```
[Docker Compose]
    ├─ Service db  (MySQL)
    ├─ Service web (PHP + Apache)
    └─ Volume mysql_data pour persistance
```

---

##  **Nettoyer (optionnel)**

Pour tout arrêter et supprimer les conteneurs, réseaux, volumes créés :

```bash
docker-compose down -v
```

# **Protéger les mots de passe dans Docker Compose**

##  **Problème initial**

Dans `docker-compose.yml`, on avait :

```yaml
environment:
  MYSQL_ROOT_PASSWORD: test123++
  MYSQL_DATABASE: businessdb
  MYSQL_USER: test
  MYSQL_PASSWORD: test123++
```

 ➜ Les mots de passe sont visibles directement en clair.

---

##  **Solution — utiliser un fichier `.env`**

###   Créer un fichier `.env`

Dans ton projet, créer un fichier `.env` :

```
MYSQL_ROOT_PASSWORD=test123++
MYSQL_DATABASE=businessdb
MYSQL_USER=test
MYSQL_PASSWORD=test123++
```

#  **Arborescence complète du projet**

```
project/
│
├── backend/
│   ├── Dockerfile
│   └── src/
│       ├── index.php
│       ├── create.php
│       ├── update.php
│       ├── delete.php
│       ├── read.php
│       ├── error.php
│       └── config.php
│
├── mysql/
│   ├── Dockerfile
│   └── script.sql
│
├── docker-compose.yml
├── .env
└── .gitignore
```


###  Modifier `docker-compose.yml`

Remplace la section `environment` par :

```yaml
environment:
  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
  MYSQL_DATABASE: ${MYSQL_DATABASE}
  MYSQL_USER: ${MYSQL_USER}
  MYSQL_PASSWORD: ${MYSQL_PASSWORD}
```
 Docker Compose va automatiquement charger les variables définies dans `.env`.

---

###  Ne pas versionner `.env`

Ajouter au fichier `.gitignore` :

```
.env
```

---

##  **Avantages**

*  Mot de passe non exposé dans `docker-compose.yml`.
*  Facile à gérer selon les environnements (dev, prod, etc.).
*  `.env` facilement exclu des commits Git.

---

##  **Résumé express pour créer `.env`**

```bash
echo "MYSQL_ROOT_PASSWORD=motDePasseFort" >> .env
echo "MYSQL_DATABASE=businessdb" >> .env
echo "MYSQL_USER=test" >> .env
echo "MYSQL_PASSWORD=motDePasseFort" >> .env
```

# **Conclusion**

 Cette méthode rend ton projet plus **sécurisé**, **modulaire** et **prêt pour une utilisation professionnelle**.




