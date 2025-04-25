# Partie I des exercice sur Git

### **Exercice 1 : Initialisation d'un dépôt Git avec Python**
**Technologie :** Python  
**Objectif :** Apprendre à initialiser un dépôt Git, faire des commits de base et pousser vers GitLab.

#### Énoncé :
1. Installez Python sur votre machine. [Lien vers les instructions](https://www.python.org/downloads/).
2. Créez un dépôt local pour gérer un script Python simple.
3. Écrivez un script `hello.py` qui imprime "Hello World!".
4. Initialisez un dépôt Git dans ce dossier, faites un premier commit et poussez le dépôt vers un nouveau projet GitLab.

#### Correction détaillée :
1. **Installation de Python :** Suivez les instructions sur le site officiel pour installer Python.
2. **Création du fichier :**
   ```bash
   mkdir mon_projet_python
   cd mon_projet_python
   echo 'print("Hello World!")' > hello.py
   ```
3. **Initialisation et commit Git :**
   ```bash
   git init
   git add hello.py
   git commit -m "Initial commit: Hello World script"
   ```
4. **Création du projet sur GitLab :** Connectez-vous à GitLab, créez un nouveau projet, copiez l'URL SSH ou HTTPS, puis poussez votre dépôt :
   ```bash
   git remote add origin <URL>
   git push -u origin master
   ```

#### Explication :
Cet exercice introduit les commandes de base de Git, ainsi que la mise en ligne d’un projet sur GitLab. Vous comprenez comment lier un dépôt local à un projet distant, ce qui est crucial pour la collaboration.

---

### **Exercice 2 : Création et Fusion d'une Branche (Node.js)**
**Technologie :** Node.js  
**Objectif :** Utiliser les branches pour tester de nouvelles fonctionnalités et fusionner dans la branche principale.

#### Énoncé :
1. Installez Node.js sur votre machine. [Lien vers les instructions](https://nodejs.org/).
2. Créez un projet Node.js avec un fichier `index.js` affichant "Hello Node!".
3. Créez une branche `nouvelle-fonctionnalite` et modifiez le message pour qu'il affiche "Hello, nouvelle fonctionnalité!".
4. Fusionnez la branche `nouvelle-fonctionnalite` avec `master` et poussez le tout vers GitLab.

#### Correction détaillée :
1. **Installation de Node.js :** Téléchargez et installez Node.js en suivant les instructions officielles.
2. **Création du projet :**
   ```bash
   mkdir mon_projet_node
   cd mon_projet_node
   echo 'console.log("Hello Node!")' > index.js
   git init
   git add index.js
   git commit -m "Initial commit: Hello Node script"
   git push -u origin master
   ```
3. **Création et modification de la branche :**
   ```bash
   git checkout -b nouvelle-fonctionnalite
   echo 'console.log("Hello, nouvelle fonctionnalité!")' > index.js
   git commit -am "Modification du message d'accueil"
   git checkout master
   git merge nouvelle-fonctionnalite
   git push
   ```

#### Explication :
Cet exercice met l'accent sur les branches, montrant comment tester une fonctionnalité sans affecter la branche principale. La fusion est aussi un aspect clé, car c'est une opération fréquente lors des collaborations.

---

### **Exercice 3 : Gestion des Pull Requests et Review de Code (React)**
**Technologie :** React  
**Objectif :** Mettre en place un workflow de collaboration via les pull requests sur GitLab.

#### Énoncé :
1. Installez React via `npx` et créez une application React simple qui affiche "Bienvenue sur React!".
2. Créez une branche `amélioration-interface` et modifiez l'interface pour afficher "Bienvenue sur React - Interface Améliorée!".
3. Poussez la branche sur GitLab et créez une Merge Request. Assignez-la à un collègue (ou à vous-même) pour une révision de code.
4. Acceptez la Merge Request et fusionnez dans la branche principale.

#### Correction détaillée :
1. **Création de l’application React :**
   ```bash
   npx create-react-app mon-projet-react
   cd mon-projet-react
   git init
   git add .
   git commit -m "Initial commit: Create React App"
   git push -u origin master
   ```
2. **Modification et création de la Merge Request :**
   ```bash
   git checkout -b amelioration-interface
   # Modifiez le code de l'interface
   git commit -am "Mise à jour de l'interface React"
   git push --set-upstream origin amelioration-interface
   ```
3. **Sur GitLab :** Créez une Merge Request, assignez-la pour révision, puis acceptez et fusionnez.
   
#### Explication :
Cet exercice introduit la collaboration via GitLab, avec la gestion des Merge Requests et des révisions de code. Ce workflow est essentiel pour des projets d'équipe.

---

### **Exercice 4 : Gestion des Conflits de Fusion (Angular)**
**Technologie :** Angular  
**Objectif :** Apprendre à résoudre les conflits de fusion lorsque plusieurs personnes modifient la même partie du code.

#### Énoncé :
1. Installez Angular en utilisant `npm install -g @angular/cli` et créez une application Angular simple.
2. Créez deux branches : `fonctionnalite-a` et `fonctionnalite-b`.
3. Modifiez un même fichier `app.component.html` sur les deux branches pour générer un conflit de fusion.
4. Tentez de fusionner les branches sur `master` et résolvez les conflits de manière appropriée.

#### Correction détaillée :
1. **Création de l’application Angular :**
   ```bash
   ng new mon-projet-angular
   cd mon-projet-angular
   git init
   git add .
   git commit -m "Initial commit: Create Angular App"
   git push -u origin master
   ```
2. **Création des branches et modifications :**
   ```bash
   git checkout -b fonctionnalite-a
   # Modifiez app.component.html
   git commit -am "Mise à jour de fonctionnalite-a"
   git checkout master
   git checkout -b fonctionnalite-b
   # Modifiez app.component.html de manière conflictuelle
   git commit -am "Mise à jour de fonctionnalite-b"
   ```
3. **Fusion et résolution des conflits :**
   ```bash
   git checkout master
   git merge fonctionnalite-a
   git merge fonctionnalite-b
   # Résolvez les conflits dans app.component.html, puis :
   git add app.component.html
   git commit -m "Résolution des conflits de fusion"
   ```

#### Explication :
Cet exercice introduit la gestion des conflits de fusion, une compétence clé pour tous les développeurs utilisant Git. Cela permet de comprendre comment résoudre les conflits et maintenir un historique de commits propre.
