### **Exercice : Utilisation de GitFlow pour gérer les branches (développement, fonctionnalités, corrections de bugs, etc.)**

---

#### **Objectif :**
Apprendre à utiliser le workflow **GitFlow** pour gérer efficacement les branches dans un projet de développement. Ce scénario inclut la gestion des branches `develop`, `feature`, `release`, `hotfix`, et `main`, avec un workflow complet.

---

### **Pré-requis :**

1. **Installer l'extension GitFlow :**
   - Si vous utilisez Git directement (sans interface graphique), installez GitFlow :
     ```bash
     sudo apt install git-flow # Sur Linux
     brew install git-flow-avh # Sur macOS
     ```
     (Sur Windows, utilisez une interface graphique comme SourceTree ou une version GitFlow compatible avec Git Bash.)

2. **Initialiser un dépôt Git :**
   - Créez un nouveau projet :
     ```bash
     git init gitflow-project
     cd gitflow-project
     echo "Ligne 1" > fichier.txt
     git add fichier.txt
     git commit -m "Initial commit"
     ```

---

### **Étapes de l'exercice :**

#### 1. **Initialiser GitFlow :**
- Exécutez la commande pour initialiser le workflow GitFlow :
  ```bash
  git flow init
  ```
  - Acceptez les noms par défaut des branches :
    - `main` : branche principale pour les versions en production.
    - `develop` : branche pour le développement actif.
    - Préfixes : `feature/`, `release/`, `hotfix/`.

---

#### 2. **Créer une nouvelle fonctionnalité :**
- Démarrez une branche `feature` pour développer une nouvelle fonctionnalité :
  ```bash
  git flow feature start feature-login
  ```
- Ajoutez des changements dans la branche :
  ```bash
  echo "Login feature implementation" > login.txt
  git add login.txt
  git commit -m "Ajout de la fonctionnalité Login"
  ```

- Terminez la branche `feature` une fois le développement terminé :
  ```bash
  git flow feature finish feature-login
  ```
  - Cette commande fusionne automatiquement `feature-login` dans `develop` et supprime la branche `feature`.

---

#### 3. **Créer une version release :**
- Une fois plusieurs fonctionnalités prêtes, créez une branche `release` :
  ```bash
  git flow release start 1.0.0
  ```
- Ajoutez des ajustements finaux (ex. mise à jour des fichiers de version) :
  ```bash
  echo "Version 1.0.0 ready for release" > release-notes.txt
  git add release-notes.txt
  git commit -m "Préparation de la version 1.0.0"
  ```

- Terminez la branche `release` pour la fusionner dans `main` et `develop` :
  ```bash
  git flow release finish 1.0.0
  ```
  - Cela génère automatiquement un tag `v1.0.0` sur la branche `main`.

---

#### 4. **Créer et corriger un bug urgent avec un hotfix :**
- Simulez un bug dans la version en production (`main`) :
  ```bash
  git checkout main
  echo "Bug detected in production" > bug.txt
  git add bug.txt
  git commit -m "Bug détecté"
  ```

- Démarrez une branche `hotfix` pour corriger le bug :
  ```bash
  git flow hotfix start fix-login-bug
  ```
- Corrigez le bug dans cette branche :
  ```bash
  echo "Bug fixed in Login feature" >> bug.txt
  git add bug.txt
  git commit -m "Correction du bug de Login"
  ```

- Terminez la branche `hotfix` pour fusionner dans `main` et `develop` :
  ```bash
  git flow hotfix finish fix-login-bug
  ```
  - Un tag sera ajouté sur la branche `main` pour marquer la nouvelle version corrigée.

---

#### 5. **Vérifiez l’historique des branches :**
- Utilisez cette commande pour visualiser l’arborescence des branches :
  ```bash
  git log --graph --oneline --all
  ```

---

### **Résumé des commandes GitFlow utilisées :**

1. **Initialisation :**
   ```bash
   git flow init
   ```

2. **Gestion des fonctionnalités (feature) :**
   - Démarrer une fonctionnalité :
     ```bash
     git flow feature start <nom_feature>
     ```
   - Terminer une fonctionnalité :
     ```bash
     git flow feature finish <nom_feature>
     ```

3. **Gestion des versions (release) :**
   - Démarrer une version :
     ```bash
     git flow release start <version>
     ```
   - Terminer une version :
     ```bash
     git flow release finish <version>
     ```

4. **Gestion des corrections urgentes (hotfix) :**
   - Démarrer une correction :
     ```bash
     git flow hotfix start <nom_hotfix>
     ```
   - Terminer une correction :
     ```bash
     git flow hotfix finish <nom_hotfix>
     ```

---

### **Extensions de l'exercice :**
1. **Collaboration avec un dépôt distant :**
   - Configurez un dépôt distant (GitHub ou GitLab).
   - Poussez les branches `develop`, `feature/*`, `release/*`, et `hotfix/*` pour simuler une collaboration avec une équipe.

2. **Ajouter des conflits :**
   - Simulez des conflits en modifiant le même fichier dans `feature` et `develop`, puis résolvez-les lors du merge.

