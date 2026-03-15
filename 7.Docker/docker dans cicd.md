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
Oui.
Voici un playbook Ansible qui reproduit exactement la logique du script Bash :

1. connexion au GitLab Container Registry
2. build de l’image Docker
3. tag de l’image
4. push vers GitLab

---

Créer le fichier **publish_gitlab_image.yml**

```yaml
---
- name: Publier une image Docker sur GitLab Container Registry
  hosts: docker_hosts
  become: false

  vars:
    # ---------------------------------------------------------
    # VARIABLES A ADAPTER
    # ---------------------------------------------------------

    # Registry GitLab
    gitlab_registry: "registry.gitlab.com"

    # Namespace et projet GitLab
    project_path: "mon_compte/mon_projet"

    # Nom local de l'image Docker
    image_name: "demo-docker"

    # Tag de l'image
    image_tag: "latest"

    # Login GitLab
    gitlab_username: "VOTRE_LOGIN"

    # Token GitLab
    gitlab_token: "VOTRE_TOKEN_ICI"

    # Dossier contenant le Dockerfile
    build_context: "/chemin/vers/le/projet"

    # Nom complet de l'image dans GitLab
    full_image_name: "{{ gitlab_registry }}/{{ project_path }}/{{ image_name }}:{{ image_tag }}"

  tasks:
    - name: Afficher le nom complet de l'image qui sera publiée
      ansible.builtin.debug:
        msg: "Image cible : {{ full_image_name }}"

    - name: Vérifier que Docker est installé
      ansible.builtin.command: docker --version
      register: docker_version
      changed_when: false

    - name: Afficher la version de Docker détectée
      ansible.builtin.debug:
        var: docker_version.stdout

    - name: Se connecter au registry GitLab avec le token
      ansible.builtin.shell: |
        echo "{{ gitlab_token }}" | docker login {{ gitlab_registry }} \
        --username {{ gitlab_username }} \
        --password-stdin
      no_log: true
      register: docker_login_result
      changed_when: true

    - name: Construire l'image Docker localement
      ansible.builtin.command:
        cmd: docker build -t {{ image_name }} .
      args:
        chdir: "{{ build_context }}"
      register: docker_build_result
      changed_when: true

    - name: Afficher le résultat du build
      ansible.builtin.debug:
        var: docker_build_result.stdout_lines

    - name: Tagger l'image pour GitLab Registry
      ansible.builtin.command:
        cmd: docker tag {{ image_name }} {{ full_image_name }}
      register: docker_tag_result
      changed_when: true

    - name: Publier l'image sur GitLab Container Registry
      ansible.builtin.command:
        cmd: docker push {{ full_image_name }}
      register: docker_push_result
      changed_when: true

    - name: Afficher le résultat du push
      ansible.builtin.debug:
        var: docker_push_result.stdout_lines

    - name: Afficher le résultat final
      ansible.builtin.debug:
        msg:
          - "Publication terminée avec succès"
          - "Image publiée : {{ full_image_name }}"
```

---

Créer le fichier **inventory.ini**

```ini
[docker_hosts]
serveur_docker ansible_host=192.168.1.50 ansible_user=ubuntu
```

---

Commande d’exécution

```bash
ansible-playbook -i inventory.ini publish_gitlab_image.yml
```

---

Remarques importantes

* La machine cible doit déjà avoir Docker installé.
* Le dossier indiqué dans **build_context** doit contenir le Dockerfile.
* Le token GitLab doit avoir au minimum :

  * read_registry
  * write_registry

---

Version un peu plus propre pour le token

Au lieu d’écrire le token directement dans le playbook, vous pouvez le passer à l’exécution :

Modifier la variable dans le playbook :

```yaml
gitlab_token: "{{ vault_gitlab_token }}"
```

Puis lancer :

```bash
ansible-playbook -i inventory.ini publish_gitlab_image.yml -e "vault_gitlab_token=VOTRE_TOKEN"
```

---

Exemple concret de valeur

* gitlab_registry : registry.gitlab.com
* project_path : bechir/devops-demo
* image_name : mon-nginx
* image_tag : v1

Résultat publié :

**registry.gitlab.com/bechir/devops-demo/mon-nginx:v1**

