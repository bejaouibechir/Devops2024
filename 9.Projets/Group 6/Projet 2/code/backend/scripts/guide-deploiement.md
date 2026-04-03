# Guide de Déploiement Backend – StockMaster

## Prérequis EC2

- **OS** : Ubuntu 22.04 LTS
- **Instance** : t3.medium minimum
- **Ports ouverts (Security Group)** : 22 (SSH), 8080 (Tomcat), 5432 (PostgreSQL), 6379 (Redis)

---

## Étape 1 – Connexion à l'EC2

```bash
ssh -i votre-cle.pem ubuntu@<IP_EC2>
```

---

## Étape 2 – Cloner le projet

```bash
sudo apt-get install -y git
git clone <URL_REPO> stockmaster
cd stockmaster/backend
```

---

## Étape 3 – Installer PostgreSQL et Redis (Docker)

```bash
chmod +x scripts/install-docker-services.sh
./scripts/install-docker-services.sh
```

Ce script installe Docker, crée les conteneurs PostgreSQL et Redis et vérifie qu'ils sont opérationnels.

> ⚠️ Si vous êtes déconnecté après l'installation de Docker, reconnectez-vous pour que les droits du groupe `docker` soient pris en compte.

Vérification manuelle :

```bash
docker ps
docker exec stockmaster-postgres pg_isready -U stockmaster
docker exec stockmaster-redis redis-cli ping   # doit retourner PONG
```

---

## Étape 4 – Installer Tomcat

```bash
chmod +x scripts/install-tomcat.sh
./scripts/install-tomcat.sh
```

Vérification :

```bash
sudo systemctl status tomcat
curl http://localhost:8080   # doit retourner la page Tomcat
```

---

## Étape 5 – Construire et Déployer le WAR

```bash
# Installer Maven si absent
sudo apt-get install -y maven

chmod +x scripts/deploy-backend.sh
./scripts/deploy-backend.sh
```

Le script :

1. Build le projet (`mvn clean package`)
2. Arrête Tomcat
3. Copie le WAR dans `/opt/tomcat/webapps/stockmaster.war`
4. Configure les variables d'environnement (DB, Redis, profil prod)
5. Redémarre Tomcat

---

## Étape 6 – Vérification

```bash
# Logs en temps réel
sudo tail -f /opt/tomcat/logs/catalina.out

# Test API
curl http://localhost:8080/stockmaster/api/reports/summary

# Swagger UI
# Ouvrir dans le navigateur : http://<IP_EC2>:8080/stockmaster/swagger-ui/index.html
```

---

## Étape 7 – Premier utilisateur (via Swagger ou curl)

```bash
curl -X POST http://localhost:8080/stockmaster/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "Admin123!",
    "email": "admin@stockmaster.com",
    "role": "STOCK_MANAGER"
  }'
```

Récupérer le token JWT dans la réponse, puis l'utiliser dans les requêtes suivantes :

```bash
curl -H "Authorization: Bearer <TOKEN>" \
     http://localhost:8080/stockmaster/api/products
```

---

## Commandes de maintenance

| Action                           | Commande                                     |
| -------------------------------- | -------------------------------------------- |
| Redémarrer Tomcat                | `sudo systemctl restart tomcat`              |
| Voir les logs                    | `sudo tail -f /opt/tomcat/logs/catalina.out` |
| Arrêter PostgreSQL               | `docker stop stockmaster-postgres`           |
| Arrêter Redis                    | `docker stop stockmaster-redis`              |
| Redéployer sans tout réinstaller | `./scripts/deploy-backend.sh`                |

---

## Variables d'environnement (setenv.sh)

Fichier généré automatiquement dans `/opt/tomcat/bin/setenv.sh` :

```bash
export SPRING_PROFILES_ACTIVE=prod
export DB_URL=jdbc:postgresql://localhost:5432/stockmaster
export DB_USERNAME=stockmaster
export DB_PASSWORD=stockmaster123
export REDIS_HOST=localhost
export REDIS_PORT=6379
```

Pour modifier un paramètre, éditer ce fichier puis `sudo systemctl restart tomcat`.
