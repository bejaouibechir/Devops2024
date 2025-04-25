# Integration Docke CICD

### **Exercice 1 : Exécuter des commandes Docker simples via un GitLab Runner (Docker-in-Docker)**

**Énoncé :**  
Configurer un pipeline CI/CD GitLab qui exécute des commandes Docker simples sur une machine distante configurée avec Docker-in-Docker (DinD). Les tâches incluent :  
- Vérifier la version Docker.  
- Construire une image à partir d’un Dockerfile simple.  
- Lister les images disponibles.  

**Solution :**  
1. **Dockerfile :**  
   ```dockerfile
   # Exemple de Dockerfile simple
   FROM alpine:latest
   CMD ["echo", "Hello from Docker!"]
   ```
2. **`.gitlab-ci.yml` :**
   ```yaml
   image: docker:latest
   services:
     - docker:dind

   variables:
     DOCKER_HOST: tcp://docker:2375
     DOCKER_TLS_CERTDIR: ""

   stages:
     - build
     - test

   build:
     stage: build
     script:
       - docker --version
       - docker build -t my-simple-image .
       - docker images
   ```
3. **Étapes détaillées :**
   - Configurer un runner avec le support Docker-in-Docker.  
   - Pousser les fichiers dans un projet GitLab.  
   - Lancer le pipeline et vérifier les logs.

---

### **Exercice 2 : Déploiement d'une solution Dockerisée simple vers une machine distante**

**Énoncé :**  
Créer une application Node.js avec un `Dockerfile`, construire l'image, et la déployer vers une machine distante configurée avec Docker.  

**Solution :**  
1. **Code source `app.js`:**
   ```javascript
   const http = require('http');
   const server = http.createServer((req, res) => {
     res.end('Hello from Node.js');
   });
   server.listen(3000, () => console.log('Server running on port 3000'));
   ```
2. **Dockerfile :**  
   ```dockerfile
   FROM node:16
   WORKDIR /app
   COPY app.js .
   CMD ["node", "app.js"]
   ```
3. **`.gitlab-ci.yml`:**  
   ```yaml
   image: docker:latest

   variables:
     DOCKER_HOST: tcp://remote-machine:2375

   stages:
     - build
     - deploy

   build:
     stage: build
     script:
       - docker build -t my-node-app .
       - docker save my-node-app > my-node-app.tar

   deploy:
     stage: deploy
     script:
       - scp my-node-app.tar user@remote-machine:/tmp
       - ssh user@remote-machine "docker load < /tmp/my-node-app.tar && docker run -d -p 3000:3000 my-node-app"
   ```

---

### **Exercice 3 : Déploiement d'une image Docker vers Docker Hub**

**Énoncé :**  
Créer une image Docker et la pousser sur Docker Hub avec un tag spécifique.  

**Solution :**  
1. **Dockerfile :**  
   (Réutiliser celui de l’exercice précédent.)  
2. **`.gitlab-ci.yml`:**  
   ```yaml
   image: docker:latest

   variables:
     DOCKER_USERNAME: "your-dockerhub-username"
     DOCKER_PASSWORD: "your-dockerhub-password"

   stages:
     - build
     - push

   build:
     stage: build
     script:
       - docker build -t my-node-app .
       - docker tag my-node-app $DOCKER_USERNAME/my-node-app:latest

   push:
     stage: push
     script:
       - echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
       - docker push $DOCKER_USERNAME/my-node-app:latest
   ```

---

### **Exercice 4 : Déploiement d'une image vers le registry GitLab**

**Énoncé :**  
Pousser une image Docker vers le registre GitLab.

**Solution :**  
1. Modifier `.gitlab-ci.yml` :
   ```yaml
   image: docker:latest

   stages:
     - build
     - push

   variables:
     CI_REGISTRY: $CI_SERVER_HOST
     CI_IMAGE: $CI_REGISTRY_IMAGE

   build:
     stage: build
     script:
       - docker build -t $CI_IMAGE .
       - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY

   push:
     stage: push
     script:
       - docker push $CI_IMAGE
   ```

---

### **Exercice 5 : Déploiement vers GitHub Container Registry**

**Énoncé :**  
Publier une image sur GitHub Container Registry.

**Solution :**  
1. Ajouter `.gitlab-ci.yml` :  
   ```yaml
   image: docker:latest

   variables:
     GITHUB_USERNAME: "your-github-username"
     GITHUB_TOKEN: "your-github-token"

   stages:
     - build
     - push

   build:
     stage: build
     script:
       - docker build -t my-node-app .
       - docker tag my-node-app ghcr.io/$GITHUB_USERNAME/my-node-app:latest

   push:
     stage: push
     script:
       - echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin
       - docker push ghcr.io/$GITHUB_USERNAME/my-node-app:latest
   ```

---

### **Exercice 6 : Installer Docker et Docker Compose via Ansible**

**Énoncé :**  
Créer un playbook Ansible pour installer Docker et Docker Compose sur une machine distante.

**Solution :**  
1. **Playbook `install-docker.yml`:**  
   ```yaml
   - hosts: remote
     become: yes
     tasks:
       - name: Install Docker dependencies
         apt:
           name: "{{ item }}"
           state: present
         with_items:
           - apt-transport-https
           - ca-certificates
           - curl
           - gnupg
           - lsb-release

       - name: Add Docker GPG key
         command: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

       - name: Add Docker repository
         lineinfile:
           path: /etc/apt/sources.list.d/docker.list
           line: "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
           state: present

       - name: Install Docker and Docker Compose
         apt:
           name: "{{ item }}"
           state: present
         with_items:
           - docker-ce
           - docker-ce-cli
           - containerd.io
   ```

---

### **Exercice 7 : Gestion du versionnement pour le déploiement**

**Énoncé :**  
Mettre en place un pipeline qui gère automatiquement des tags basés sur le numéro de version.

**Solution :**  
Ajouter une tâche dans `.gitlab-ci.yml` pour incrémenter et tagger les versions.

---

### **Exercice 8 : Installation via Docker Compose (Flask + MySQL)**

**Énoncé :**  
Installer une solution Flask + MySQL sur une machine distante via un pipeline GitLab.

**Solution :**  
1. **`docker-compose.yml`:**  
   ```yaml
   version: '3.8'
   services:
     db:
       image: mysql:5.7
       environment:
         MYSQL_ROOT_PASSWORD: root
         MYSQL_DATABASE: flaskdb
     app:
       build: .
       ports:
         - "5000:5000"
       depends_on:
         - db
   ```
2. **Pipeline et script de déploiement détaillés.**

Pour chaque exercice, je peux fournir des détails supplémentaires si nécessaire. Vous pouvez choisir un ou plusieurs exercices pour commencer !
