# Solution StockMaster — Guide DevOps complet

## Architecture et progression pédagogique

```
PHASE 1 : Mono-machine (1 VM)       PHASE 2 : Ansible             PHASE 3 : Jenkins
┌──────────────────────┐            ┌─────────────────┐           ┌──────────────────┐
│  Nginx               │            │ Playbooks        │           │ pipeline-databases│
│  Tomcat + WAR        │  ──────►   │ automatisés      │  ──────►  │ pipeline-app      │
│  PostgreSQL          │            │ testés séparément│           │ Jenkinsfile master│
│  Redis (Docker)      │            │ avec leurs undo  │           │ + Tests Newman    │
└──────────────────────┘            └─────────────────┘           └──────────────────┘
```

---

## PHASE 1 — Montage mono-machine (découverte manuelle)

L'objectif est de comprendre chaque brique avant de l'automatiser.
Toutes les commandes s'exécutent directement sur la VM (connexion SSH).

### Pré-requis VM

Ubuntu 22.04, 4 Go RAM, 20 Go disque.
Connexion : `ssh -i ~/.ssh/bechir.pem ubuntu@<IP_VM>`

### Étape 1 — PostgreSQL 15

```bash
# Installation
sudo apt update && sudo apt install -y postgresql postgresql-contrib

# Démarrer et activer
sudo systemctl enable --now postgresql

# Créer l'utilisateur et la base
sudo -u postgres psql <<SQL
CREATE USER stockmaster WITH PASSWORD 'stockmaster123';
CREATE DATABASE stockmaster OWNER stockmaster;
\c stockmaster
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm;
SQL

# Autoriser les connexions locales depuis l'applicatif
# (pour mono-machine, localhost suffit, pas besoin de modifier pg_hba.conf)

# Vérification
sudo -u postgres psql -c "SELECT usename FROM pg_user;"
# → affiche stockmaster

sudo -u postgres psql -d stockmaster -c "SELECT 1;"
# → retourne 1
```

### Étape 2 — Redis 7 (Docker)

```bash
# Installer Docker
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker

# Lancer Redis
sudo docker run -d \
  --name redis \
  --restart always \
  -p 6379:6379 \
  redis:7-alpine

# Vérification
sudo docker exec redis redis-cli ping
# → PONG
```

### Étape 3 — Java 17 + Tomcat 10.1

```bash
# Java 17
sudo apt install -y openjdk-17-jdk
java -version
# → openjdk version "17"

# Télécharger et installer Tomcat
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.54/bin/apache-tomcat-10.1.54.tar.gz -P /tmpcd
sudo mkdir -p /opt/tomcat
cd /tmp
sudo tar xvf apache-tomcat-10.1.54.tar.gz -C /opt/tomcat --strip-components=1
sudo chown -R ubuntu:ubuntu /opt/tomcat

# Créer le service systemd
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<'EOF'
[Unit]
Description=Tomcat 10.1
After=network.target

[Service]
Type=forking
User=ubuntu
Group=ubuntu
Environment="CATALINA_HOME=/opt/tomcat"
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Créer setenv.sh avec les variables Spring Boot
sudo tee /opt/tomcat/bin/setenv.sh > /dev/null <<'EOF'
#!/usr/bin/env bash
export SPRING_PROFILES_ACTIVE=prod
export DB_URL=jdbc:postgresql://localhost:5432/stockmaster
export DB_USERNAME=stockmaster
export DB_PASSWORD=stockmaster123
export REDIS_HOST=localhost
export REDIS_PORT=6379
EOF
sudo chmod +x /opt/tomcat/bin/setenv.sh
sudo chown ubuntu:ubuntu /opt/tomcat/bin/setenv.sh

# Démarrer Tomcat
sudo systemctl daemon-reload
sudo systemctl enable --now tomcat

# Vérification (HTTP 200 ou 302 = Tomcat tourne)
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/
```

### Étape 4 — Installer Maven et builder le WAR

Maven est l'outil de build Java. Il lit le fichier `pom.xml` du projet et produit un fichier `.war` déployable sur Tomcat.

```bash
# 1. Installer Maven
sudo apt install -y maven
mvn -version
# → Apache Maven 3.x.x (Java 17)
# Détecter automatiquement le chemin réel de Maven
MAVEN_BIN="$(readlink -f "$(command -v mvn)")"
MAVEN_HOME="$(dirname "$(dirname "$MAVEN_BIN")")"

# Ajouter MAVEN_HOME dans ~/.bashrc si absent

grep -q '^export MAVEN_HOME=' ~/.bashrc ||
 echo "export MAVEN_HOME=$MAVEN_HOME" >> ~/.bashrc

# Ajouter Maven au PATH si absent
grep -q 'MAVEN_HOME/bin' 
~/.bashrc || echo 'export PATH=$MAVEN_HOME/bin:$PATH' >> ~/.bashrc

# Recharger la configuration Bash
source ~/.bashrc

# Vérifier
echo "$MAVEN_HOME"
mvn -version

# 2. Aller dans le dossier backend du projet
cd ~/stockmaster/backend

# 3. Builder le WAR
#    -DskipTests  : ne pas lancer les tests unitaires (plus rapide)
#    -Pprod       : activer le profil "prod" (utilise application-prod.yml)
#    clean        : nettoyer les anciens builds
#    package      : compiler + créer le .war dans target/
mvn -DskipTests -Pprod clean package

# Résultat attendu en fin de logs :
# [INFO] BUILD SUCCESS

# 4. Vérifier que le WAR a bien été produit
ls -lh target/stockmaster-backend-1.0.0.war
# → -rw-r--r-- ...  ~50M  stockmaster-backend-1.0.0.war
```

> Si le build échoue : vérifier que `java -version` retourne Java 17.

### Étape 5 — Déployer et tester le WAR

```bash
# Déployer le WAR dans Tomcat
sudo cp target/stockmaster-backend-1.0.0.war /opt/tomcat/webapps/stockmaster.war
sudo chown ubuntu:ubuntu /opt/tomcat/webapps/stockmaster.war

# Redémarrer Tomcat pour charger le WAR
sudo systemctl restart tomcat

# Suivre les logs de démarrage en temps réel
sudo tail -f /opt/tomcat/logs/catalina.out
# Attendre le message : "Server startup in [X] milliseconds"
# Ctrl+C pour quitter le suivi des logs*
```

**Test 1 — Swagger UI accessible :**

http://@IP_ADDRESS:8080/stockmaster/swagger-ui/index.html

**Test 2 — Login réel avec l'API :**

http://@IP_ADDRESS:8080/stockmaster/api/auth/register

{
  "username": "admin",
  "password": "Admin123!",
  "email": "string",
  "role": "ADMIN"
}

http://@IP_ADDRESS:8080/stockmaster/api/auth/login

{
  "username": "admin",
  "password": "Admin123!"
}

**5.1 — Installer Node.js 20 LTS**

Vite 5 nécessite Node.js >= 18. On installe Node 20 via le dépôt officiel NodeSource :

```bash
# Installer nvm
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Recharger le shell
source ~/.bashrc

# Installer Node 20
nvm install 20
nvm use 20

# Vérifier
node -v
npm -v
```

> Ne pas utiliser `sudo apt install nodejs` sans le dépôt NodeSource — la version Ubuntu est trop ancienne (v12) et Vite refusera de builder.

**5.2 — Builder le frontend**

```bash
# Aller dans le dossier frontend du projet
cd ~/stockmaster/frontend

# Installer les dépendances npm
# (lit package.json et télécharge node_modules/)
npm install

# Builder pour la production
# VITE_API_URL : l'URL que le navigateur utilisera pour appeler l'API
# Elle doit pointer vers Nginx (port 80), pas vers Tomcat directement
VITE_API_URL=http://@IP_ADDRESS/api 
npm run build

# Vérifier que le build a réussi
ls dist/
# → index.html  assets/  ...
# Produit : dist/

# Installer Nginx (sur la VM)
sudo apt install -y nginx

# Créer le dossier de déploiement
sudo mkdir -p /var/www/stockmaster/frontend

# Copier les fichiers buildés
sudo cp -r ~/stockmaster/frontend/dist/* /var/www/stockmaster/frontend/

IP_PRIVEE=$(hostname -I | awk '{print $1}')
echo "$IP_PRIVEE"

# Configurer Nginx
sudo tee /etc/nginx/sites-available/stockmaster > /dev/null << 'EOF'
upstream backend_pool {
    server 127.0.0.1:8080;
}

server {
    listen 80;
    server_name _;

    location /api/ {
        proxy_pass http://backend_pool/stockmaster/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /swagger-ui/ {
        proxy_pass http://backend_pool/stockmaster/swagger-ui/;
    }

    location / {
        root /var/www/stockmaster/frontend;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/stockmaster /etc/nginx/sites-enabled/stockmaster
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx

# Vérification
curl -s -o /dev/null -w "%{http_code}" http://localhost/
# → 200

curl -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Admin123!"}'
# → {"token":"eyJ..."}  (token JWT)
```

**Accès navigateur :** `http://IP_VM/` — Login : `admin` / `Admin123!`

---

## PHASE 2 — Ansible (automatisation par briques)

### Structure des fichiers

```
solution/ansible/
├── inventory.ini             ← IPs des machines
├── group_vars/all.yml        ← toutes les variables
├── vars/secrets.yml          ← mots de passe (non commité)
├── templates/
│   ├── postgresql.conf.j2
│   ├── pg_hba.conf.j2
│   ├── docker-compose-redis.yml.j2
│   ├── tomcat.service.j2
│   ├── setenv.sh.j2
│   └── nginx-stockmaster.conf.j2
├── 01-postgres.yml           ← installer PostgreSQL
├── 01-postgres-undo.yml      ← désinstaller PostgreSQL
├── 02-redis.yml              ← installer Redis (Docker)
├── 02-redis-undo.yml
├── 03-tomcat.yml             ← installer Java + Tomcat
├── 03-tomcat-undo.yml
├── 04-backend-deploy.yml     ← déployer le WAR
├── 04-backend-deploy-undo.yml
├── 05-frontend-nginx.yml     ← déployer Nginx + frontend
├── 05-frontend-nginx-undo.yml
└── 09-smoke-tests.yml        ← tester tout
```

### Principes Ansible intégrés dans les playbooks

| Principe        | Où on le voit                                       |
| --------------- | --------------------------------------------------- |
| Variables       | `group_vars/all.yml` + `vars/secrets.yml`           |
| Templates J2    | Tous les fichiers de conf (postgresql.conf, nginx…) |
| Handlers        | Restart postgresql, tomcat, reload nginx            |
| Conditions when | Idempotence : créer user PG si absent               |
| Tags            | `--tags install,configure,healthcheck,undo`         |
| changed_when    | Health checks marqués "non-transformateurs"         |
| Retries/until   | Attendre Spring Boot / Redis au démarrage           |

### Étape 0 — Préparer l'inventaire

Éditer `ansible/inventory.ini` :

```ini
[db]
db1 ansible_host=<IP_DB> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/bechir.pem

[backend]
back1 ansible_host=<IP_BACK1> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/bechir.pem

[frontend]
front1 ansible_host=<IP_FRONT> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/bechir.pem

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

> Pour mono-machine : mettre la même IP dans les 3 groupes.

Créer `ansible/vars/secrets.yml` :

```yaml
pg_app_password: "stockmaster123"
pg_repl_password: "replicator123"
```

Tester la connectivité :

```bash
cd solution/ansible
ansible all -i inventory.ini -m ping
# Toutes les machines → pong
```

### Étape 1 — PostgreSQL

```bash
cd solution/ansible

# Installer et configurer
ansible-playbook -i inventory.ini 01-postgres.yml -e @vars/secrets.yml

# Tester uniquement le health check
ansible-playbook -i inventory.ini 01-postgres.yml -e @vars/secrets.yml --tags healthcheck

# Undo (désinstaller proprement)
ansible-playbook -i inventory.ini 01-postgres-undo.yml
```

### Étape 2 — Redis

```bash
# Installer Docker + Redis
ansible-playbook -i inventory.ini 02-redis.yml

# Test uniquement
ansible-playbook -i inventory.ini 02-redis.yml --tags healthcheck

# Undo
ansible-playbook -i inventory.ini 02-redis-undo.yml
```

### Étape 3 — Tomcat

```bash
# Installer Java + Tomcat + setenv.sh
ansible-playbook -i inventory.ini 03-tomcat.yml -e @vars/secrets.yml

# Tester la disponibilité HTTP
ansible-playbook -i inventory.ini 03-tomcat.yml -e @vars/secrets.yml --tags healthcheck

# Undo
ansible-playbook -i inventory.ini 03-tomcat-undo.yml
```

### Étape 4 — Déployer le WAR

```bash
# Builder d'abord le WAR sur M-Central
cd ~/stockmaster/backend && mvn -DskipTests -Pprod clean package

# Déployer
cd ~/stockmaster/solution/ansible
ansible-playbook -i inventory.ini 04-backend-deploy.yml \
  -e @vars/secrets.yml \
  -e "backend_war_src=$(pwd)/../../backend/target/stockmaster-backend-1.0.0.war"

# Undo (restaure le backup ou supprime le WAR)
ansible-playbook -i inventory.ini 04-backend-deploy-undo.yml
```

### Étape 5 — Frontend + Nginx

```bash
# Builder le frontend sur M-Central
FRONT_IP=$(grep 'front1' inventory.ini | grep -oP 'ansible_host=\K[^ ]+')
cd ~/stockmaster/frontend && npm ci && VITE_API_URL=http://${FRONT_IP}/api npm run build

# Déployer
cd ~/stockmaster/solution/ansible
ansible-playbook -i inventory.ini 05-frontend-nginx.yml \
  -e "frontend_dist_src=$(pwd)/../../frontend/dist"

# Undo
ansible-playbook -i inventory.ini 05-frontend-nginx-undo.yml
```

### Étape 6 — Smoke tests complets

```bash
# Tout tester en une commande
ansible-playbook -i inventory.ini 09-smoke-tests.yml

# Tags disponibles pour cibler
ansible-playbook -i inventory.ini 09-smoke-tests.yml --tags db
ansible-playbook -i inventory.ini 09-smoke-tests.yml --tags backend
ansible-playbook -i inventory.ini 09-smoke-tests.yml --tags frontend
ansible-playbook -i inventory.ini 09-smoke-tests.yml --tags e2e
```

---

## PHASE 3 — Jenkins (automatisation complète)

### Architecture des pipelines

```
Jenkinsfile (Master)
├── Phase 1 → pipeline-databases (PostgreSQL + Redis en PARALLÈLE)
└── Phase 2 → pipeline-app       (Build WAR + Build npm → Deploy + Newman)
```

### Prérequis Jenkins

**Installer Jenkins** sur M-Central :

```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
  sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update && sudo apt install -y jenkins
sudo systemctl enable --now jenkins
```

Accès : `http://<IP_M_CENTRAL>:8080` — mot de passe : `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

**Vérifier les outils nécessaires sur M-Central** :

```bash
ansible --version    # >= 2.14
java -version        # Java 17
mvn -version         # Maven 3.8+
node -v              # >= 18
npm -v
```

### Créer les Credentials Jenkins

Jenkins → Manage Jenkins → Credentials → Global → Add Credential

| ID                | Type                          | Contenu                         |
| ----------------- | ----------------------------- | ------------------------------- |
| `stockmaster-ssh` | SSH Username with private key | user: `ubuntu`, clé: bechir.pem |

> Les mots de passe PostgreSQL sont passés comme `password()` paramètres dans les pipelines — ils n'ont pas besoin d'être dans les Credentials.

### Créer les jobs Jenkins

Créer 3 jobs de type **Pipeline** :

| Nom du job           | Script Path                                       |
| -------------------- | ------------------------------------------------- |
| `pipeline-databases` | `solution/jenkins/pipeline-databases.Jenkinsfile` |
| `pipeline-app`       | `solution/jenkins/pipeline-app.Jenkinsfile`       |
| `pipeline-master`    | `solution/jenkins/Jenkinsfile`                    |

Pour chaque job : New Item → Pipeline → Pipeline from SCM → Git → URL du repo → branch `main` → Script Path = chemin ci-dessus.

### Lancer le déploiement

Lancer **pipeline-master** avec :

| Paramètre          | Valeur                                        |
| ------------------ | --------------------------------------------- |
| `DB_IP`            | IP de la VM base de données                   |
| `BACKEND_IP`       | IP backend (ou plusieurs séparés par virgule) |
| `FRONT_IP`         | IP frontend/Nginx                             |
| `PG_APP_PASSWORD`  | stockmaster123                                |
| `PG_REPL_PASSWORD` | replicator123                                 |
| `RUN_NEWMAN`       | ✅ coché                                       |

Le pipeline enchaîne automatiquement :

1. Installation PostgreSQL + Redis (en parallèle)
2. Build WAR Maven + Build frontend npm (en parallèle)
3. Déploiement Tomcat + WAR
4. Déploiement Nginx + frontend (en parallèle avec le backend)
5. Tests Newman (10 scénarios API)

### Principes Jenkins utilisés

| Principe          | Où                                                       |
| ----------------- | -------------------------------------------------------- |
| `parameters{}`    | IPs et mots de passe configurables sans modifier le code |
| `environment{}`   | Variables globales disponibles dans tous les stages      |
| `parallel{}`      | PostgreSQL + Redis installés simultanément               |
| `when{}`          | Newman skip si `RUN_NEWMAN=false`                        |
| `post{}`          | Message succès/échec + nettoyage du fichier secrets      |
| `build job{}`     | Orchestrateur appelle les sous-pipelines                 |
| `withCredentials` | Clé SSH jamais visible dans les logs                     |
| `junit`           | Rapport de tests Newman publié dans Jenkins              |

---

## Tests Newman — Collection Postman

La collection `postman/stockmaster-newman.json` teste 10 scénarios API dans l'ordre :

1. Login admin → capture du JWT token
2. Mauvais credentials → HTTP 401/403
3. Lister les catégories → tableau JSON
4. Créer une catégorie → récupère l'ID
5. Créer un fournisseur → récupère l'ID
6. Créer un produit (avec categoryId + supplierId) → récupère l'ID
7. Lire le produit par ID → vérification des données
8. Entrée stock (ENTRY +50) → HTTP 200/201
9. Rapport dashboard → JSON non vide
10. Cleanup → supprimer le produit de test

**Lancer manuellement** (depuis M-Central) :

```bash
# Installer Newman
npm install -g newman

# Lancer sur l'API backend directement
newman run solution/postman/stockmaster-newman.json \
  --env-var "base_url=http://<IP_BACKEND>:8080/stockmaster/api" \
  --reporters cli

# Lancer via Nginx (load balancer)
newman run solution/postman/stockmaster-newman.json \
  --env-var "base_url=http://<IP_FRONT>/api" \
  --reporters cli
```

---

## Référence rapide — Toutes les commandes

```bash

# Connectivité Ansible

ansible all -i ansible/inventory.ini -m ping

# Déploiement complet step-by-step

ansible-playbook -i ansible/inventory.ini ansible/01-postgres.yml        -e @ansible/vars/secrets.yml
ansible-playbook -i ansible/inventory.ini ansible/02-redis.yml
ansible-playbook -i ansible/inventory.ini ansible/03-tomcat.yml          -e @ansible/vars/secrets.yml
ansible-playbook -i ansible/inventory.ini ansible/04-backend-deploy.yml  -e @ansible/vars/secrets.yml -e backend_war_src=/chemin/vers/stockmaster-backend-1.0.0.war
ansible-playbook -i ansible/inventory.ini ansible/05-frontend-nginx.yml  -e frontend_dist_src=/chemin/vers/dist
ansible-playbook -i ansible/inventory.ini ansible/09-smoke-tests.yml

# Rollback complet

ansible-playbook -i ansible/inventory.ini ansible/05-frontend-nginx-undo.yml
ansible-playbook -i ansible/inventory.ini ansible/04-backend-deploy-undo.yml
ansible-playbook -i ansible/inventory.ini ansible/03-tomcat-undo.yml
ansible-playbook -i ansible/inventory.ini ansible/02-redis-undo.yml
ansible-playbook -i ansible/inventory.ini ansibl