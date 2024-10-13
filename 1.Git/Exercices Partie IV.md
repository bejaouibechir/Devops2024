# Exercices sur Git/Github Partie IV


### **Exercice 16 : Rétroportage de Correctifs via Git Revert (Node.js)**
**Technologie :** Node.js  
**Objectif :** Utiliser `git revert` pour annuler un commit problématique tout en maintenant l’historique.

#### Énoncé :
1. Créez un projet Node.js avec une fonctionnalité qui introduit un bug.
2. Commitez la fonctionnalité, puis utilisez `git revert` pour annuler le commit qui a introduit le bug sans supprimer le commit de l’historique.
3. Poussez les changements vers GitLab et vérifiez que le commit d’annulation est bien présent.

#### Correction détaillée :
1. **Création du projet et ajout de la fonctionnalité :**
   ```bash
   mkdir projet_node_revert
   cd projet_node_revert
   npm init -y
   echo 'console.log("Fonctionnalité avec un bug")' > index.js
   git init
   git add .
   git commit -m "Ajout d'une fonctionnalité avec un bug"
   ```
2. **Utilisation de `git revert` :**
   ```bash
   git revert HEAD
   git push origin master
   ```

#### Explication :
`git revert` permet d’annuler un commit spécifique tout en conservant l’historique complet. Cela est utile lorsque vous souhaitez marquer une correction tout en maintenant la traçabilité des erreurs et de leurs corrections.

---

### **Exercice 17 : Création et Utilisation de Git Stash pour la Gestion du Contexte (Angular)**
**Technologie :** Angular  
**Objectif :** Utiliser `git stash` pour sauvegarder des modifications en cours et les réappliquer ultérieurement.

#### Énoncé :
1. Créez un projet Angular avec des modifications en cours.
2. Utilisez `git stash` pour enregistrer les changements sans les committer, puis basculez vers une autre branche.
3. Récupérez les modifications stachées et appliquez-les à la branche d’origine.

#### Correction détaillée :
1. **Initialisation et ajout des modifications :**
   ```bash
   ng new projet_angular_stash
   cd projet_angular_stash
   git init
   # Faites quelques modifications sans les committer
   git add .
   ```
2. **Utilisation de `git stash` :**
   ```bash
   git stash
   git checkout -b autre-branche
   # Faites des changements sur autre-branche
   git checkout master
   git stash apply
   ```

#### Explication :
`git stash` est utile pour mettre temporairement de côté des modifications en cours afin de basculer sur une autre tâche, puis les réintégrer plus tard, facilitant ainsi la gestion du contexte.

---

### **Exercice 18 : Gestion des Environnements avec GitLab Environments (Spring Boot)**
**Technologie :** Spring Boot  
**Objectif :** Utiliser GitLab pour gérer des environnements (développement, staging, production) et configurer le déploiement continu pour chaque environnement.

#### Énoncé :
1. Créez une application Spring Boot et un dépôt GitLab avec des branches `develop`, `staging`, et `production`.
2. Configurez GitLab Environments pour déployer automatiquement la branche `develop` sur l’environnement de développement, `staging` sur l’environnement de pré-production, et `production` sur l’environnement de production.
3. Testez les déploiements automatiques.

#### Correction détaillée :
1. **Création des branches et configuration des environnements :**
   - Créez des branches `develop`, `staging`, et `production`.
   - Dans GitLab, allez dans **Settings** > **CI/CD** > **Environments** et configurez chaque environnement pour déployer les branches correspondantes.
2. **Ajout du fichier `.gitlab-ci.yml` pour chaque environnement :**
   ```yaml
   stages:
     - deploy

   deploy_development:
     stage: deploy
     script:
       - echo "Déploiement sur développement"
     only:
       - develop

   deploy_staging:
     stage: deploy
     script:
       - echo "Déploiement sur pré-production"
     only:
       - staging

   deploy_production:
     stage: deploy
     script:
       - echo "Déploiement en production"
     only:
       - production
   ```

#### Explication :
GitLab Environments permet de configurer des environnements spécifiques pour chaque branche, facilitant ainsi le déploiement continu et la gestion des différentes étapes du cycle de vie du logiciel.

---

### **Exercice 19 : Analyse des Contributions avec Git Shortlog (Python)**
**Technologie :** Python  
**Objectif :** Utiliser la commande `git shortlog` pour analyser les contributions de chaque membre de l’équipe sur un projet Python.

#### Énoncé :
1. Créez un projet Python et ajoutez plusieurs commits avec différents auteurs.
2. Utilisez `git shortlog` pour générer un rapport des contributions par auteur.
3. Interprétez le rapport pour comprendre la répartition des contributions dans le projet.

#### Correction détaillée :
1. **Création du projet et ajout de commits :**
   ```bash
   mkdir projet_python_shortlog
   cd projet_python_shortlog
   git init
   echo 'print("Premier commit")' > main.py
   git add .
   git commit -m "Premier commit" --author="Auteur1 <auteur1@example.com>"
   
   echo 'print("Deuxième commit")' > main.py
   git commit -am "Deuxième commit" --author="Auteur2 <auteur2@example.com>"
   ```
2. **Utilisation de `git shortlog` :**
   ```bash
   git shortlog -s -n
   ```

#### Explication :
`git shortlog` est un outil pratique pour analyser les contributions de chaque membre de l’équipe et obtenir des statistiques sur la participation de chacun dans le projet.

---

### **Exercice 20 : Gestion des Pull et Fetch pour Suivre les Mises à Jour du Projet (React)**
**Technologie :** React  
**Objectif :** Apprendre à utiliser `git fetch` et `git pull` pour suivre les changements d’un projet distant sans écraser vos modifications locales.

#### Énoncé :
1. Créez une application React et partagez-la sur GitLab.
2. Effectuez des modifications locales, mais avant de les committer, utilisez `git fetch` pour vérifier les mises à jour du dépôt distant.
3. Si des mises à jour sont disponibles, appliquez-les avec `git pull` et fusionnez les modifications en résolvant les conflits éventuels.

#### Correction détaillée :
1. **Création de l’application et ajout des modifications :**
   ```bash
   npx create-react-app projet_react_fetch
   cd projet_react_fetch
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <url_gitlab>
   git push -u origin master
   ```
2. **Utilisation de `git fetch` et `git pull` :**
   - Effectuez des modifications locales et ajoutez un nouveau commit sans le pousser.
   - Exécutez `git fetch` pour voir s’il y a des mises à jour :
     ```bash
     git fetch origin master
     ```
   - Si des mises à jour existent, utilisez `git pull` :
     ```bash
     git pull origin master
     ```

#### Explication :
`git fetch` permet de récupérer les informations de mise à jour d’un dépôt distant sans les appliquer. `git pull` intègre les changements dans la branche courante. Ce flux de travail permet de rester à jour sans risquer d'écraser les modifications locales.


