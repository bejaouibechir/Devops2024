# Deployer un rôle sur ansible galaxy

Pour déployer un **rôle Ansible** directement sur **Ansible Galaxy** (sans utiliser de collection), voici les étapes à suivre. Ansible Galaxy est conçu pour accueillir à la fois des collections et des rôles individuels, bien qu'il soit recommandé de regrouper les rôles dans des collections pour une meilleure gestion. Cependant, vous pouvez toujours publier un rôle seul.

### Étapes pour Publier un Rôle Ansible sur Galaxy

1. **Créer un Compte sur Ansible Galaxy**

   - Si vous n'avez pas encore de compte, inscrivez-vous sur [Ansible Galaxy](https://galaxy.ansible.com/).
   - Créez un **namespace** sous votre profil. Le namespace correspond souvent à votre nom d'utilisateur ou au nom de votre organisation.

2. **Structurer le Rôle**

   Organisez le rôle en suivant la structure recommandée par Ansible Galaxy.

   Par exemple, pour un rôle `install_docker` :

   ```
   install_docker/
   ├── README.md              # Documentation du rôle
   ├── tasks/
   │   └── main.yml           # Fichier principal des tâches
   ├── handlers/
   │   └── main.yml           # Gestionnaire pour redémarrer Docker si nécessaire
   ├── meta/
   │   └── main.yml           # Fichier meta pour les dépendances et informations
   ├── defaults/
   │   └── main.yml           # Variables par défaut pour le rôle
   ├── vars/
   │   └── main.yml           # Variables spécifiques au rôle (optionnel)
   ├── files/
   └── templates/
   ```

3. **Configurer le Fichier `meta/main.yml`**

   Le fichier `meta/main.yml` contient les métadonnées du rôle. Ce fichier est crucial pour Ansible Galaxy, car il spécifie les informations de votre rôle et ses éventuelles dépendances.

   **Exemple de fichier : `install_docker/meta/main.yml`**

   ```yaml
   galaxy_info:
     author: "VotreNom"
     description: "Un rôle pour installer Docker sur Ubuntu et CentOS."
     company: "VotreEntreprise"
     license: "MIT"
     min_ansible_version: "2.9"
     platforms:
       - name: Ubuntu
         versions:
           - bionic
           - focal
       - name: EL
         versions:
           - 7
           - 8
     categories:
       - cloud
       - tools
     tags:
       - docker
       - container
       - install
   dependencies: []
   ```

4. **Ajouter la Documentation dans `README.md`**

   Un bon fichier `README.md` est essentiel pour expliquer comment utiliser votre rôle. Indiquez les prérequis, les variables, et des exemples d'utilisation.

   **Exemple de fichier `install_docker/README.md` :**

   ```markdown
   # Rôle Ansible : install_docker

   Ce rôle installe Docker sur les distributions Ubuntu et CentOS.

   ## Variables

   - `docker_version`: Version de Docker à installer (par défaut: `latest`).

   ## Exemple d'utilisation

   ```yaml
   - hosts: all
     roles:
       - role: install_docker
         docker_version: "20.10"
   ```

   ## Prérequis

   Ce rôle requiert Ansible >= 2.9.
   ```

5. **Initialiser Git et Créer un Dépôt sur GitHub**

   Ansible Galaxy utilise GitHub (ou GitLab, Bitbucket) pour héberger les rôles. Assurez-vous que votre rôle est dans un dépôt GitHub public.

   - Initialisez un dépôt Git :

     ```bash
     cd install_docker
     git init
     git add .
     git commit -m "Initial commit for install_docker role"
     ```

   - Créez un dépôt sur [GitHub](https://github.com/) avec le nom `install_docker`.
   - Poussez le dépôt local vers GitHub :

     ```bash
     git remote add origin https://github.com/VotreNomUtilisateur/install_docker.git
     git push -u origin main
     ```

6. **Publier le Rôle sur Ansible Galaxy**

   Utilisez la commande suivante pour publier le rôle directement depuis le dépôt GitHub vers Ansible Galaxy. Remplacez `VotreNomUtilisateur` par votre nom d’utilisateur Ansible Galaxy.

   ```bash
   ansible-galaxy role import VotreNomUtilisateur install_docker
   ```

   Cela va lancer le processus d'importation du rôle sur Ansible Galaxy. Vous pourrez voir les informations de publication et des détails sur la compatibilité.

7. **Mise à Jour du Rôle**

   Si vous apportez des modifications à votre rôle et que vous souhaitez les publier sur Ansible Galaxy, il vous suffit de :

   - Commiter et pousser les changements sur GitHub :

     ```bash
     git add .
     git commit -m "Mise à jour du rôle install_docker"
     git push
     ```

   - Puis d'importer à nouveau le rôle sur Galaxy :

     ```bash
     ansible-galaxy role import VotreNomUtilisateur install_docker
     ```

8. **Installation et Utilisation du Rôle depuis Galaxy**

   Une fois le rôle publié, les utilisateurs peuvent l’installer depuis Ansible Galaxy avec :

   ```bash
   ansible-galaxy role install VotreNomUtilisateur.install_docker
   ```

   Ensuite, ils pourront l'utiliser dans leurs playbooks comme suit :

   ```yaml
   - hosts: all
     roles:
       - role: VotreNomUtilisateur.install_docker
         docker_version: "20.10"
   ```

### Résumé

Ces étapes permettent de structurer, configurer, et publier un rôle Ansible sur Galaxy pour qu'il soit réutilisable par la communauté. Avec Ansible Galaxy, vous pouvez centraliser vos rôles, les partager avec d'autres utilisateurs, et les maintenir facilement à jour.
