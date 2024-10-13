# Exercices sur Git/Gitlab Partie III

Continuons avec des exercices plus avancés qui explorent des fonctionnalités complexes de Git et GitLab. Ces exercices sont conçus pour s’appuyer sur des fonctionnalités comme la relecture de code, les hooks, les stratégies de déploiement, et l’analyse d’historique.

---

### **Exercice 10 : Mise en Place de Git Hooks pour les Tests Automatisés (Node.js)**
**Technologie :** Node.js  
**Objectif :** Utiliser des Git hooks pour exécuter des tests automatiquement avant chaque commit.

#### Énoncé :
1. Créez un projet Node.js simple avec un test en utilisant [Jest](https://jestjs.io/).
2. Configurez un hook `pre-commit` pour exécuter les tests chaque fois qu’un commit est effectué.
3. Testez le hook en effectuant des commits et vérifiez que le hook empêche de valider un commit si les tests échouent.

#### Correction détaillée :
1. **Initialisation du projet et ajout des tests :**
   ```bash
   mkdir projet_node_hooks
   cd projet_node_hooks
   npm init -y
   npm install jest --save-dev
   echo 'test("addition", () => { expect(1 + 1).toBe(2); });' > test.js
   git init
   git add .
   git commit -m "Initial commit with Jest test"
   ```
2. **Création du hook `pre-commit` :**
   - Créez un dossier `.git/hooks/` et un fichier `pre-commit` :
     ```bash
     echo '#!/bin/sh\nnpm test' > .git/hooks/pre-commit
     chmod +x .git/hooks/pre-commit
     ```
3. **Test du hook :**
   - Essayez d’effectuer un commit après avoir introduit une erreur dans les tests. Le hook `pre-commit` empêchera le commit tant que les tests échouent.

#### Explication :
Les Git hooks permettent d’automatiser certaines tâches lors d'événements Git spécifiques, comme un commit, un push, etc. Cela aide à maintenir la qualité du code en empêchant le commit de modifications qui ne passent pas les tests.



### **Exercice 11 : Mise en Place d'un Déploiement Automatisé avec GitLab CI/CD (Spring Boot)**
**Technologie :** Spring Boot  
**Objectif :** Configurer un pipeline CI/CD qui déploie une application Spring Boot vers un serveur distant ou un service comme Heroku après chaque commit.

#### Énoncé :
1. Créez une application Spring Boot et un dépôt GitLab associé.
2. Ajoutez un fichier `.gitlab-ci.yml` pour configurer le déploiement automatique de votre application.
3. Testez le déploiement en effectuant un commit dans le dépôt GitLab et en vérifiant que l'application est bien déployée.

#### Correction détaillée :
1. **Création de l’application Spring Boot :**
   ```bash
   spring init --dependencies=web projet_spring
   cd projet_spring
   git init
   git add .
   git commit -m "Initial commit: Spring Boot project"
   git push -u origin master
   ```
2. **Configuration du fichier `.gitlab-ci.yml` :**
   ```yaml
   stages:
     - build
     - deploy

   build:
     stage: build
     image: maven:3.6.3-jdk-11
     script:
       - mvn clean package

   deploy:
     stage: deploy
     image: alpine
     script:
       - echo "Déploiement de l'application"
       # Déploiement vers Heroku ou autre
   ```

#### Explication :
Cet exercice montre comment mettre en place un pipeline GitLab CI/CD pour automatiser le déploiement d’une application Spring Boot. Cela permet de déployer automatiquement les changements sans intervention manuelle, ce qui améliore l’efficacité.

---

### **Exercice 12 : Bisect pour Identifier les Bugs (Python)**
**Technologie :** Python  
**Objectif :** Utiliser la commande `git bisect` pour identifier un commit spécifique qui a introduit un bug dans un projet.

#### Énoncé :
1. Créez un projet Python avec plusieurs versions successives, et introduisez un bug à un certain moment.
2. Utilisez `git bisect` pour trouver le commit responsable du bug.
3. Corrigez le bug et effectuez un nouveau commit.

#### Correction détaillée :
1. **Création du projet avec commits successifs :**
   ```bash
   mkdir projet_python_bisect
   cd projet_python_bisect
   git init
   echo 'print("Version 1")' > main.py
   git add .
   git commit -m "Version 1"
   
   echo 'print("Version 2")' > main.py
   git commit -am "Version 2"
   
   echo 'print("Version 3 - Bug introduit")' > main.py
   git commit -am "Version 3 - Bug introduit"
   
   echo 'print("Version 4")' > main.py
   git commit -am "Version 4"
   ```
2. **Utilisation de `git bisect` pour trouver le bug :**
   ```bash
   git bisect start
   git bisect bad HEAD
   git bisect good <commit_id_version_2>
   ```
   - Git va maintenant faire un bisect sur les commits pour trouver celui qui contient le bug. À chaque étape, vous pouvez tester et marquer chaque commit comme `good` ou `bad` pour affiner la recherche.
   
#### Explication :
`git bisect` est une commande puissante pour identifier le moment exact où un bug a été introduit dans un projet, permettant de résoudre rapidement les problèmes en examinant l’historique des commits.

---

### **Exercice 13 : Git Cherry-Pick pour Gérer des Corrections Rapides (Angular)**
**Technologie :** Angular  
**Objectif :** Utiliser `git cherry-pick` pour appliquer des commits spécifiques d’une branche à une autre sans effectuer une fusion complète.

#### Énoncé :
1. Créez une application Angular avec deux branches, `develop` et `hotfix`.
2. Sur la branche `develop`, ajoutez une fonctionnalité, puis sur la branche `hotfix`, corrigez un bug critique.
3. Utilisez `git cherry-pick` pour appliquer le correctif de `hotfix` à `develop` sans fusionner les branches.

#### Correction détaillée :
1. **Création des branches et commits :**
   ```bash
   git checkout -b develop
   # Ajoutez une fonctionnalité sur develop
   git commit -am "Ajout de fonctionnalité sur develop"
   
   git checkout -b hotfix
   # Corrigez le bug
   git commit -am "Correction de bug critique"
   ```
2. **Utilisation de `git cherry-pick` :**
   ```bash
   git checkout develop
   git cherry-pick <commit_id_du_correctif_hotfix>
   ```

#### Explication :
`git cherry-pick` est utile pour appliquer des corrections spécifiques entre branches sans tout fusionner, ce qui est fréquent pour des correctifs rapides qui doivent être présents dans plusieurs branches.

---

### **Exercice 14 : Analyse et Visualisation des Statistiques de Projet avec GitLab Insights**
**Technologie :** Toutes  
**Objectif :** Utiliser GitLab Insights pour analyser les statistiques de développement, comme les contributions par utilisateur et la vitesse des merges.

#### Énoncé :
1. Activez l'outil GitLab Insights pour votre dépôt.
2. Analysez les contributions des utilisateurs, la fréquence des commits, et le délai moyen pour les Merge Requests.
3. Interprétez les résultats pour identifier des axes d’amélioration dans le développement collaboratif.

#### Correction détaillée :
1. **Accéder à GitLab Insights :**
   - Dans GitLab, allez dans **Project** > **Analytics** > **Insights**.
2. **Interprétation des données :**
   - Utilisez les graphiques fournis pour visualiser la répartition des contributions et identifier des tendances. Par exemple, si les Merge Requests prennent plus de temps que prévu, cela pourrait signifier que le code nécessite davantage de révisions ou que l'équipe est surchargée.

#### Explication :
GitLab Insights permet d’avoir une vue d’ensemble des contributions de chaque membre et de la rapidité d’exécution des tâches, facilitant l’amélioration des processus de développement.

---

### **Exercice 15 : Utilisation de Git Reflog pour Récupérer des Commits Perdus (React)**
**Technologie :** React  
**Objectif :** Apprendre à utiliser `git reflog` pour restaurer un commit qui aurait été perdu lors d’un rebase ou d’un reset.

#### Énoncé :
1. Créez une application React, effectuez plusieurs commits, puis supprimez un commit avec `git reset`.
2. Utilisez `git reflog` pour retrouver et restaurer le commit supprimé.
3. Vérifiez que le commit est à nouveau dans l’historique.

#### Correction détaillée :
1. **Création du projet et commits :**
   ```bash
   npx create-react-app projet_react_reflog
   cd projet_react_reflog
   git init
   git add .
   git commit -m "Initial commit"
   
   echo 'console.log("Second commit")' >> src/App.js
   git commit -am "Second commit"
   
   echo 'console.log("Third commit")' >> src/App

.js
   git commit -am "Third commit"
   ```
2. **Suppression et récupération d’un commit :**
   ```bash
   git reset --hard HEAD~1
   git reflog
   git checkout <commit_id_perdu>
   ```

#### Explication :
Cet exercice démontre comment utiliser `git reflog`, un outil puissant pour récupérer des commits supprimés par erreur, ce qui est crucial dans les situations d’urgence.

