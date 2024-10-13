# Exercices sur Git/Gitlab Partie II

### **Exercice 5 : Rebase Interactif et Organisation des Commits (Spring Boot)**
**Technologie :** Spring Boot  
**Objectif :** Utiliser le rebase interactif pour organiser des commits avant de les pousser sur la branche principale.

#### Énoncé :
1. Installez Spring Boot en suivant les [instructions officielles](https://spring.io/guides/gs/spring-boot/).
2. Créez une application Spring Boot simple qui affiche "Bonjour, Spring!".
3. Créez trois commits sur la branche `dev` :
   - Ajout de la classe principale.
   - Ajout d’une route HTTP GET à l’application.
   - Ajout de la documentation dans les commentaires.
4. Utilisez le rebase interactif pour fusionner les trois commits en un seul avant de les pousser sur la branche principale.

#### Correction détaillée :
1. **Création de l’application Spring Boot :**
   ```bash
   mkdir mon_projet_spring
   cd mon_projet_spring
   spring init --dependencies=web mon_projet_spring
   cd mon_projet_spring
   git init
   git add .
   git commit -m "Initial commit: Spring Boot project"
   ```
2. **Création de commits et rebase :**
   ```bash
   # Créez la branche dev
   git checkout -b dev
   
   # Ajout de la classe principale
   # Modifiez votre application Spring Boot ici...
   git add .
   git commit -m "Ajout de la classe principale"
   
   # Ajout d’une route GET
   # Ajoutez une route HTTP GET dans votre code
   git add .
   git commit -m "Ajout de la route GET"
   
   # Ajout de la documentation
   # Documentez votre code
   git add .
   git commit -m "Ajout de la documentation"
   
   # Rebase interactif
   git rebase -i HEAD~3
   ```
   Dans l'éditeur, vous pouvez "squash" les commits en un seul, puis pousser la branche dev :
   ```bash
   git checkout master
   git merge dev
   git push
   ```

#### Explication :
Cet exercice montre comment utiliser le rebase interactif pour organiser et simplifier l’historique des commits. Cela peut rendre les changements plus clairs et faciliter la revue de code.

---

### **Exercice 6 : Mise en Place d'un CI/CD Basique (GitLab CI avec Node.js)**
**Technologie :** Node.js  
**Objectif :** Configurer un pipeline CI/CD dans GitLab pour automatiser les tests.

#### Énoncé :
1. Créez un projet Node.js et ajoutez des tests avec [Jest](https://jestjs.io/).
2. Ajoutez un fichier `.gitlab-ci.yml` pour exécuter les tests automatiquement à chaque push.
3. Assurez-vous que le pipeline GitLab exécute les tests avec succès.

#### Correction détaillée :
1. **Initialisez le projet avec des tests Jest :**
   ```bash
   mkdir projet_node_ci
   cd projet_node_ci
   npm init -y
   npm install jest --save-dev
   echo 'test("adds 1 + 2 to equal 3", () => { expect(1 + 2).toBe(3); });' > sum.test.js
   git init
   git add .
   git commit -m "Initial commit with Jest test"
   ```
2. **Ajoutez le fichier `.gitlab-ci.yml` :**
   ```yaml
   stages:
     - test

   test:
     stage: test
     image: node:latest
     script:
       - npm install
       - npm test
   ```
   Ajoutez, commitez et poussez sur GitLab :
   ```bash
   git add .gitlab-ci.yml
   git commit -m "Ajout de CI pour les tests"
   git push -u origin master
   ```

#### Explication :
Cet exercice introduit les concepts de CI/CD avec GitLab. Le pipeline permet de s’assurer que le code fonctionne correctement à chaque modification en automatisant les tests.

---

### **Exercice 7 : Utilisation des Tags pour la Gestion des Versions (React)**
**Technologie :** React  
**Objectif :** Utiliser des tags Git pour gérer les versions d’une application React.

#### Énoncé :
1. Créez une application React avec deux fonctionnalités principales et créez un tag `v1.0.0` une fois que la première fonctionnalité est implémentée.
2. Implémentez la deuxième fonctionnalité et créez un nouveau tag `v1.1.0`.
3. Poussez les tags vers GitLab et vérifiez qu'ils apparaissent dans l’interface.

#### Correction détaillée :
1. **Initialisez l’application React et ajoutez des fonctionnalités :**
   ```bash
   npx create-react-app gestion-version
   cd gestion-version
   # Ajoutez la première fonctionnalité
   git init
   git add .
   git commit -m "Initial commit: Fonctionnalité 1"
   git tag v1.0.0
   ```
2. **Ajoutez la deuxième fonctionnalité et créez un tag :**
   ```bash
   # Ajoutez la deuxième fonctionnalité
   git add .
   git commit -m "Ajout de la fonctionnalité 2"
   git tag v1.1.0
   git push origin --tags
   ```

#### Explication :
Les tags sont essentiels pour marquer des versions spécifiques d’une application, rendant facile la gestion des versions dans les environnements de développement et de production.

---

### **Exercice 8 : Manipulation des Submodules pour un Projet Modularisé (Python et JavaScript)**
**Technologie :** Python, Node.js  
**Objectif :** Utiliser des submodules Git pour gérer des projets dépendants.

#### Énoncé :
1. Créez deux projets, l’un en Python et l’autre en Node.js.
2. Créez un dépôt principal qui inclut ces deux projets comme submodules.
3. Poussez le dépôt principal vers GitLab, et vérifiez que les submodules sont bien référencés.

#### Correction détaillée :
1. **Initialisez les projets et le dépôt principal :**
   ```bash
   mkdir projet_principal
   cd projet_principal
   git init
   git submodule add <URL_DU_DEPOT_PYTHON>
   git submodule add <URL_DU_DEPOT_NODEJS>
   git commit -m "Ajout des submodules Python et Node.js"
   git push
   ```

#### Explication :
Cet exercice montre comment utiliser les submodules pour inclure des projets indépendants dans un dépôt principal, ce qui est utile pour gérer des projets complexes avec des dépendances multiples.

---

### **Exercice 9 : Protection des Branches et Validation des Commits (GitLab)**  
**Technologie :** Toutes  
**Objectif :** Mettre en place des règles de protection de branche et des validations de commits dans GitLab.

#### Énoncé :
1. Sur votre dépôt GitLab, créez une branche `main` et protégez-la contre les commits directs.
2. Créez une branche `feature` et poussez-y des modifications.
3. Créez une Merge Request depuis `feature` vers `main` pour voir la protection de branche en action.

#### Correction détaillée :
1. **Protection de la branche :**
   - Allez dans le dépôt sur GitLab, section **Settings** > **Repository**.
   - Dans **Protected Branches**, ajoutez la branche `main` et définissez des règles pour la protéger contre les pushes directs.
2. **Création d’une branche et Merge Request :**
   ```bash
   git checkout -b feature
   # Effectuez des modifications
   git add .
   git commit -m "Modifications sur la branche feature"
   git push origin feature
   ```
   - Sur GitLab, créez une Merge Request et fusionnez-la pour valider la protection de la branche.

#### Explication :
Les protections de branches permettent de s’assurer que seules des modifications validées passent dans la branche principale, minimisant ainsi le risque d’erreurs.

