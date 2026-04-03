# Guide de déploiement — StockMaster Frontend

## Prérequis

- Node.js 20+ installé sur la machine de build
- Accès SSH à l'EC2 (si déploiement distant)
- Tomcat 10.1 actif sur l'EC2 (déjà configuré pour le backend)
- L'API backend répond sur `http://IP_EC2:8080/stockmaster/api`

---

## Option A — Déploiement local → Tomcat sur l'EC2

### 1. Sur votre machine locale, builder le projet

```bash
cd projet1/frontend

# Si l'IP a changé, mettez à jour le .env.production
echo "VITE_API_URL=http://IP_EC2:8080/stockmaster/api" > .env.production

# Installer les dépendances
npm install

# Builder pour la production
npm run build
```

Le dossier `dist/` est généré avec les fichiers statiques optimisés.

### 2. Transférer le build vers l'EC2

```bash
# Créer le dossier sur l'EC2
ssh ubuntu@IP_EC2 "sudo mkdir -p /opt/tomcat/webapps/frontend"

# Copier les fichiers
scp -r dist/* ubuntu@IP_EC2:/tmp/frontend-build/

# Sur l'EC2 : déplacer vers Tomcat
ssh ubuntu@IP_EC2 "sudo cp -r /tmp/frontend-build/* /opt/tomcat/webapps/frontend/"
```

### 3. Ajouter le web.xml (routing SPA)

```bash
ssh ubuntu@IP_EC2 "sudo mkdir -p /opt/tomcat/webapps/frontend/WEB-INF"
ssh ubuntu@IP_EC2 "sudo tee /opt/tomcat/webapps/frontend/WEB-INF/web.xml > /dev/null" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee" version="5.0">
  <display-name>StockMaster Frontend</display-name>
  <error-page>
    <error-code>404</error-code>
    <location>/index.html</location>
  </error-page>
</web-app>
EOF
```

> ℹ️ Avec **HashRouter**, cette étape est facultative car les URLs contiennent `#` et Tomcat n'a pas besoin de réécriture.

---

## Option B — Script automatisé (si Node.js sur l'EC2)

```bash
# Sur l'EC2 directement
cd ~/stockmaster/frontend
chmod +x scripts/deploy-frontend.sh
./scripts/deploy-frontend.sh 13.49.229.69
```

---

## Accès après déploiement

| URL                                                    | Description       |
| ------------------------------------------------------ | ----------------- |
| `http://IP_EC2:8080/frontend/`                         | Application React |
| `http://IP_EC2:8080/stockmaster/swagger-ui/index.html` | API Swagger       |

**Login** : `admin` / `Admin123!`

---

## Structure du déploiement sur Tomcat

```
/opt/tomcat/webapps/
├── stockmaster/          ← Backend WAR (Spring Boot)
│   └── api/...
└── frontend/             ← Frontend React (build statique)
    ├── index.html
    ├── assets/
    │   ├── index-[hash].js
    │   └── index-[hash].css
    └── WEB-INF/
        └── web.xml
```

---

## Test en local (développement)

```bash
# Démarrer le serveur de dev Vite
npm run dev
# → http://localhost:3000

# Ou avec Docker
docker build -t stockmaster-frontend .
docker run -p 3000:80 stockmaster-frontend
# → http://localhost:3000
```

---

## Points d'attention

| Point            | Détail                                                                                                             |
| ---------------- | ------------------------------------------------------------------------------------------------------------------ |
| **IP dynamique** | Vérifier l'IP EC2 au démarrage et mettre à jour `.env.production` avant le build                                   |
| **HashRouter**   | Les URLs sont de la forme `http://IP/#/dashboard` — fonctionne sans config Nginx/Tomcat                            |
| **CORS**         | Le backend autorise `allowedOrigins("*")` — aucun blocage côté serveur                                             |
| **JWT**          | Le token est stocké dans `localStorage` — valide 24h (selon config backend)                                        |
| **Port**         | Le frontend est sur le port **8080** (même Tomcat), le backend aussi — ils coexistent via des contextes différents |

---

## Commandes utiles sur l'EC2

```bash
# Vérifier que Tomcat sert les fichiers
curl -I http://localhost:8080/frontend/

# Logs Tomcat
sudo tail -f /opt/tomcat/logs/catalina.out

# Redémarrer Tomcat si nécessaire
sudo systemctl restart tomcat

# Vérifier les webapps déployées
ls /opt/tomcat/webapps/
```
