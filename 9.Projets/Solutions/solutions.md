### **Solution Complète**

---

### **1. Dockerfiles**

#### **Backend (Flask API)**
`backend/Dockerfile`
```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["python", "app.py"]
```

#### **Frontend (HTML/CSS/JavaScript)**
`frontend/Dockerfile`
```dockerfile
FROM nginx:alpine

COPY . /usr/share/nginx/html
```

#### **Database (MySQL)**
`database/Dockerfile`
```dockerfile
FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD=password
ENV MYSQL_DATABASE=produits_app

COPY init.sql /docker-entrypoint-initdb.d/
```

---

### **2. Docker Compose**

`docker-compose.yml`
```yaml
version: '3.8'

services:
  db:
    build: ./database
    container_name: mysql_db
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: produits_app

  backend:
    build: ./backend
    container_name: flask_api
    ports:
      - "5000:5000"
    depends_on:
      - db

  frontend:
    build: ./frontend
    container_name: web_app
    ports:
      - "80:80"
    depends_on:
      - backend
```

---

### **3. Playbooks**

#### **Playbook 1 : Installer Docker et Docker Compose**

`ansible/install_docker.yml`
```yaml
- hosts: all
  become: true
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install required packages
      apt:
        name: 
          - apt-transport-https
          - ca-certificates
          - curl
          - software-properties-common
        state: present

    - name: Add Docker GPG key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present

    - name: Add Docker repository
      apt_repository:
        repo: deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable
        state: present

    - name: Install Docker
      apt:
        name: 
          - docker-ce
          - docker-ce-cli
          - containerd.io
        state: present

    - name: Install Docker Compose
      get_url:
        url: https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-x86_64
        dest: /usr/local/bin/docker-compose
        mode: '0755'

    - name: Ensure Docker service is running
      service:
        name: docker
        state: started
        enabled: true
```

---

#### **Playbook 2 : Générer et Pousser les Images Docker**

`ansible/build_and_push_images.yml`
```yaml
- hosts: all
  become: true
  vars:
    dockerhub_username: "{{ lookup('env', 'DOCKERHUB_USERNAME') }}"
    dockerhub_password: "{{ lookup('env', 'DOCKERHUB_PASSWORD') }}"
  tasks:
    - name: Login to DockerHub
      shell: |
        echo "{{ dockerhub_password }}" | docker login --username "{{ dockerhub_username }}" --password-stdin

    - name: Build Backend Image
      shell: docker build -t {{ dockerhub_username }}/flask_api ./backend

    - name: Push Backend Image to DockerHub
      shell: docker push {{ dockerhub_username }}/flask_api

    - name: Build Frontend Image
      shell: docker build -t {{ dockerhub_username }}/web_app ./frontend

    - name: Push Frontend Image to DockerHub
      shell: docker push {{ dockerhub_username }}/web_app

    - name: Build Database Image
      shell: docker build -t {{ dockerhub_username }}/mysql_db ./database

    - name: Push Database Image to DockerHub
      shell: docker push {{ dockerhub_username }}/mysql_db
```

---

#### **Playbook 3 : Exécuter Docker Compose**

`ansible/deploy_app.yml`
```yaml
- hosts: all
  become: true
  tasks:
    - name: Copy Docker Compose file to remote server
      copy:
        src: docker-compose.yml
        dest: /home/ubuntu/docker-compose.yml

    - name: Start Application with Docker Compose
      shell: |
        docker-compose -f /home/ubuntu/docker-compose.yml up -d
```

---

### **4. Fichier Hosts pour Ansible**

`ansible/hosts`
```ini
[remote]
<IP_ADRESSE_MACH_DISTANTE>
```

---

### **5. Jenkinsfile**

`Jenkinsfile`
```groovy
pipeline {
    agent any
    environment {
        DOCKERHUB_USERNAME = credentials('dockerhub-username')
        DOCKERHUB_PASSWORD = credentials('dockerhub-password')
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://gitlab.com/votre-projet.git'
            }
        }

        stage('Build and Push Images') {
            steps {
                script {
                    sh '''
                        ansible-playbook -i ansible/hosts ansible/build_and_push_images.yml
                    '''
                }
            }
        }

        stage('Deploy Application') {
            steps {
                script {
                    sh '''
                        ansible-playbook -i ansible/hosts ansible/deploy_app.yml
                    '''
                }
            }
        }
    }
}
```

---

### **Structure Complète du Projet**

```plaintext
project/
├── backend/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── index.html
│   ├── style.css
│   ├── app.js
│   └── Dockerfile
├── database/
│   ├── init.sql
│   └── Dockerfile
├── ansible/
│   ├── install_docker.yml
│   ├── build_and_push_images.yml
│   ├── deploy_app.yml
│   └── hosts
├── docker-compose.yml
└── Jenkinsfile
```

---

### **Explications**

1. **Dockerfiles** :
   - Chaque Dockerfile est conçu pour construire les images des différentes couches de l'application.

2. **Docker Compose** :
   - Définit les services pour la base de données, l'API backend, et le frontend. Les conteneurs sont configurés pour se dépendre mutuellement.

3. **Playbooks** :
   - `install_docker.yml` : Installe Docker et Docker Compose sur la machine distante.
   - `build_and_push_images.yml` : Construit et pousse les images vers Docker Hub en utilisant les credentials Jenkins.
   - `deploy_app.yml` : Déploie l'application en utilisant Docker Compose sur la machine distante.

4. **Fichier Hosts** :
   - Contient les adresses IP des machines distantes.

5. **Jenkinsfile** :
   - Pipeline CI/CD intégrant toutes les étapes : clonage, génération des images, publication, et déploiement.

---

Avec cette solution, tout est prêt pour déployer une application CRUD conteneurisée dans un environnement DevOps.
