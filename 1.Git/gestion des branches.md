### Exercices sur la gestion des branches avec GitHub, GitLab, Merge, Rebase et Git Flow

---

#### **Exercice 1 : Créer et basculer entre des branches locales**
1. **Initialisation :**
   ```bash
   mkdir git-branches-demo
   cd git-branches-demo
   git init
   echo "Hello World" > demo.txt
   git add demo.txt
   git commit -m "Initial commit"
   ```

2. **Créer et basculer sur une nouvelle branche :**
   ```bash
   git branch feature1
   git checkout feature1
   echo "New feature in progress" >> demo.txt
   git commit -am "Work on feature1"
   ```

3. **Basculer à nouveau sur `main` :**
   ```bash
   git checkout main
   cat demo.txt  # Le contenu n'a pas changé
   ```

**Objectif atteint :** Comprendre la création et le basculement des branches locales.

---

#### **Exercice 2 : Publier une branche sur GitHub/GitLab**
1. **Ajout du dépôt distant :**
   ```bash
   git remote add origin https://<TOKEN>@github.com/<USERNAME>/git-branches-demo.git
   ```

2. **Pousser la branche `feature1` :**
   ```bash
   git checkout feature1
   git push -u origin feature1
   ```

3. **Vérification :** Accédez à votre dépôt sur GitHub/GitLab et observez la nouvelle branche.

**Objectif atteint :** Synchroniser une branche locale avec un dépôt distant.

---

#### **Exercice 3 : Fusionner une branche dans `main` sans conflit**
1. **Fusion :**
   ```bash
   git checkout main
   git merge feature1
   git push origin main
   ```

2. **Vérification sur GitHub/GitLab :** Confirmez que les modifications de `feature1` sont dans `main`.

**Objectif atteint :** Apprendre le processus de fusion simple.

---

#### **Exercice 4 : Créer une Merge Request sur GitHub**
1. **Créer une Pull Request (PR) :**
   - Sur GitHub, allez sur l’onglet **Pull Requests**.
   - Créez une PR pour fusionner `feature1` dans `main`.

2. **Acceptez la PR**.

**Objectif atteint :** Apprendre à gérer les fusions via GitHub.

---

#### **Exercice 5 : Différence entre `merge` et `rebase`**
1. **Fusion avec `merge` :**
   ```bash
   git checkout main
   git merge feature1
   ```

2. **Création d’un historique clair avec `rebase` :**
   ```bash
   git checkout feature1
   git rebase main
   git push -f origin feature1  # Attention au force push
   ```

**Objectif atteint :** Comprendre la différence entre `merge` et `rebase`.

---

#### **Exercice 6 : Résolution de conflit en local**
1. **Créer un conflit :**
   - Sur `main` :
     ```bash
     echo "Line from main" >> demo.txt
     git commit -am "Update from main"
     ```
   - Sur `feature1` :
     ```bash
     echo "Line from feature1" >> demo.txt
     git commit -am "Update from feature1"
     ```

2. **Fusionner les branches :**
   ```bash
   git checkout main
   git merge feature1
   ```

3. **Résoudre le conflit dans `demo.txt`, puis :**
   ```bash
   git add demo.txt
   git commit
   ```

**Objectif atteint :** Résoudre un conflit localement.

---

#### **Exercice 7 : Résolution de conflit sur GitHub/GitLab**
1. Créez une PR de `feature1` vers `main` sur GitHub.
2. Simulez un conflit en modifiant le même fichier sur GitHub dans la branche `main`.
3. Résolvez le conflit via l’interface GitHub.

**Objectif atteint :** Résolution de conflits en ligne.

---

#### **Exercice 8 : Suppression d’une branche locale et distante**
1. **Supprimer une branche localement :**
   ```bash
   git branch -d feature1
   ```

2. **Supprimer la branche sur le dépôt distant :**
   ```bash
   git push origin --delete feature1
   ```

**Objectif atteint :** Gérer les branches inutiles.

---

#### **Exercice 9 : Travailler avec plusieurs collaborateurs**
1. **Collaborateur 1 :**
   - Crée une branche `feature2`, fait une modification, et pousse la branche.

2. **Collaborateur 2 :**
   - Tire la branche et continue le travail :
     ```bash
     git fetch origin
     git checkout feature2
     ```

**Objectif atteint :** Collaboration sur une branche distante.

---

#### **Exercice 10 : Synchronisation des branches distantes**
1. **Créer une branche sur GitHub/GitLab**.
2. **Récupérer cette branche localement :**
   ```bash
   git fetch origin
   git checkout -b new-branch origin/new-branch
   ```

**Objectif atteint :** Travailler avec des branches créées à distance.

---

#### **Exercice 11 : Installer et utiliser Git Flow**
1. **Installation :**
   ```bash
   git flow init
   ```
   - Acceptez les conventions par défaut.

2. **Création d’une branche de fonctionnalité :**
   ```bash
   git flow feature start featureX
   echo "Git Flow Demo" >> demo.txt
   git add demo.txt
   git flow feature finish featureX
   ```

3. **Création d’une branche de release :**
   ```bash
   git flow release start 1.0.0
   git flow release finish 1.0.0
   ```

4. **Vérifiez sur GitHub/GitLab que les branches sont créées et poussées correctement.**

**Objectif atteint :** Apprendre à gérer le cycle de vie des branches avec Git Flow.

---
# Les cas de conflits de branches

Voici une proposition détaillée des 5 exercices pour résoudre les conflits entre branches :

---

### **Exercice 1 : Résolution de conflits entre deux branches locales**
#### Objectif :
Simuler un conflit entre deux branches locales sur un fichier commun et le résoudre manuellement.

#### Étapes :
1. **Créer un nouveau dépôt local :**
   ```bash
   git init conflit-local
   cd conflit-local
   echo "Ligne 1" > fichier.txt
   git add fichier.txt
   git commit -m "Initial commit"
   ```

2. **Créer deux branches locales :**
   ```bash
   git branch brancheA
   git branch brancheB
   ```

3. **Modifier le fichier sur `brancheA` :**
   ```bash
   git checkout brancheA
   echo "Modification par brancheA" >> fichier.txt
   git commit -am "Modification sur brancheA"
   ```

4. **Modifier le même fichier sur `brancheB` :**
   ```bash
   git checkout brancheB
   echo "Modification par brancheB" >> fichier.txt
   git commit -am "Modification sur brancheB"
   ```

5. **Fusionner `brancheA` dans `brancheB` pour provoquer un conflit :**
   ```bash
   git merge brancheA
   ```

6. **Résolution du conflit :**
   - Ouvrir le fichier `fichier.txt`.
   - Résoudre manuellement les conflits en gardant ou modifiant les lignes conflictuelles.
   - Ajouter le fichier résolu :
     ```bash
     git add fichier.txt
     git commit -m "Résolution du conflit"
     ```

7. **Vérifier le résultat :**
   ```bash
   git log --graph --oneline --all
   ```

## Utilisation d'un outil de merge tool

### **Exercice : Résolution de conflits avec un MergeTool**

#### Objectif :
Simuler un conflit entre deux branches locales et utiliser un outil de merge (comme `meld`, `kdiff3`, `vimdiff`, ou autre) pour résoudre les conflits graphiquement.

---

### **Étapes de l'exercice :**

#### 1. **Créer un nouveau dépôt local :**
```bash
git init conflit-mergetool
cd conflit-mergetool
echo "Ligne 1" > fichier.txt
git add fichier.txt
git commit -m "Initial commit"
```

---

#### 2. **Créer deux branches :**
```bash
git branch brancheA
git branch brancheB
```

---

#### 3. **Modifier le fichier dans `brancheA` :**
```bash
git checkout brancheA
echo "Modification par brancheA" >> fichier.txt
git commit -am "Modification sur brancheA"
```

---

#### 4. **Modifier le même fichier dans `brancheB` :**
```bash
git checkout brancheB
echo "Modification par brancheB" >> fichier.txt
git commit -am "Modification sur brancheB"
```

---

#### 5. **Provoquer un conflit :**
- Rester sur `brancheB` et tenter de fusionner `brancheA` :
```bash
git merge brancheA
```
- Vous verrez un message indiquant qu'un conflit a été détecté :
```
CONFLICT (content): Merge conflict in fichier.txt
Automatic merge failed; fix conflicts and then commit the result.
```

---

#### 6. **Configurer un outil de merge :**
- Configurer un outil de merge si ce n'est pas déjà fait. Exemple avec `meld` :
```bash
git config --global merge.tool meld
git config --global mergetool.prompt false
```

- Si un autre outil est préféré, remplacez `meld` par `kdiff3`, `vimdiff`, etc.

---

#### 7. **Lancer l'outil de merge pour résoudre les conflits :**
```bash
git mergetool
```

- Le fichier avec conflit (`fichier.txt`) s'ouvrira dans l'outil configuré.
- Les sections conflictuelles seront affichées, avec les options suivantes :
  - **Local (HEAD)** : Modifications de `brancheB`.
  - **Remote** : Modifications de `brancheA`.
  - **Base** : Version initiale commune.
  - **Merged** : Zone pour construire la version finale résolue.

- Résolvez le conflit en choisissant ou combinant les parties pertinentes des branches.

---

#### 8. **Valider la résolution :**
- Une fois la résolution effectuée, validez les changements :
```bash
git add fichier.txt
git commit -m "Résolution de conflit avec un mergetool"
```

---

#### 9. **Vérifier le résultat :**
- Confirmez que la fusion est complète et que l'historique est propre :
```bash
git log --graph --oneline --all
```

---

#### **Extension de l'exercice :**

1. **Tester avec différents outils :**
   - Configurez un autre outil de merge (comme `kdiff3` ou `vimdiff`) et répétez l'exercice pour comparer les interfaces.

2. **Ajouter un conflit supplémentaire :**
   - Créez un deuxième fichier pour provoquer un autre conflit et testez la résolution avec un autre mergetool.

---

Cet exercice permettra de se familiariser avec la résolution graphique des conflits via des outils dédiés, renforçant ainsi la gestion efficace des conflits dans des projets complexes.




---

### **Exercice 2 : Résolution de conflit entre une branche locale et une branche distante**
#### Objectif :
Simuler un conflit entre une branche locale et la branche équivalente distante, puis le résoudre.

#### Étapes :
1. **Configurer un dépôt distant (GitHub ou GitLab) :**
   - Initialiser un dépôt local comme dans l'Exercice 1.
   - Créer un dépôt distant et le lier :
     ```bash
     git remote add origin <url_du_depot>
     git push -u origin main
     ```

2. **Créer une branche locale :**
   ```bash
   git branch brancheLocale
   git push -u origin brancheLocale
   ```

3. **Modifier un fichier dans la branche locale et pousser :**
   ```bash
   git checkout brancheLocale
   echo "Modification locale" >> fichier.txt
   git commit -am "Modification locale"
   git push
   ```

4. **Modifier le même fichier directement dans l'interface Web du dépôt distant :**
   - Modifier le fichier `fichier.txt` et valider les modifications sur la branche `brancheLocale`.

5. **Tirer les changements distants pour provoquer un conflit :**
   ```bash
   git pull
   ```

6. **Résolution du conflit :**
   - Ouvrir le fichier conflictué et résoudre les conflits.
   - Ajouter et valider :
     ```bash
     git add fichier.txt
     git commit -m "Résolution de conflit avec le dépôt distant"
     git push
     ```

---

### **Exercice 3 : Merge Request normal sur GitLab**
#### Objectif :
Simuler un merge request sans conflit.

#### Étapes :
1. **Créer un dépôt GitLab et initialiser un projet :**
   - Créer un dépôt sur GitLab.
   - Initialiser un dépôt local, configurer le dépôt distant et pousser le code initial.

2. **Créer deux branches sur GitLab :**
   ```bash
   git checkout -b feature1
   git push -u origin feature1
   ```

3. **Modifier un fichier sur `feature1` :**
   ```bash
   echo "Nouvelle fonctionnalité" >> fichier.txt
   git commit -am "Ajout de la fonctionnalité"
   git push
   ```

4. **Créer un Merge Request (MR) sur GitLab :**
   - Accéder à l'interface GitLab.
   - Demander la fusion de `feature1` vers `main`.
   - Valider le merge sans conflit.

---

### **Exercice 4 : Merge Request avec conflit sur GitLab**
#### Objectif :
Simuler un conflit sur un merge request dans GitLab et le résoudre.

#### Étapes :
1. **Créer une nouvelle branche `feature2` :**
   ```bash
   git checkout -b feature2
   git push -u origin feature2
   ```

2. **Modifier le même fichier sur `main` et `feature2` pour provoquer un conflit :**
   - Sur `main` :
     ```bash
     git checkout main
     echo "Modification sur main" >> fichier.txt
     git commit -am "Modification sur main"
     git push
     ```

   - Sur `feature2` :
     ```bash
     git checkout feature2
     echo "Modification sur feature2" >> fichier.txt
     git commit -am "Modification sur feature2"
     git push
     ```

3. **Créer un Merge Request de `feature2` vers `main` dans GitLab.**
   - Observer les conflits signalés par GitLab.

4. **Résoudre les conflits dans l’interface GitLab.**
   - Accéder à l’éditeur de résolution de conflit.
   - Fusionner une fois les conflits résolus.

---

### **Exercice 5 : Merge Request avec conflit sur GitHub**
#### Objectif :
Simuler un conflit sur un pull request dans GitHub et le résoudre.

#### Étapes :
1. **Créer un dépôt GitHub et initialiser un projet.**
2. **Créer deux branches : `feature3` et `main`.**
   - Pousser les modifications sur chaque branche comme dans l'Exercice 4.
3. **Créer un Pull Request de `feature3` vers `main` dans GitHub.**
   - Observer les conflits signalés.
4. **Résoudre les conflits dans l’interface GitHub ou localement.**
   - Si résolu localement :
     ```bash
     git fetch origin
     git merge origin/main
     # Résoudre les conflits
     git add fichier.txt
     git commit -m "Résolution des conflits pour GitHub"
     git push
     ```




### Résultat attendu
- Une compréhension approfondie des branches locales et distantes.
- Maitrise de la gestion des conflits et des fusions.
- Pratique de Git Flow dans un projet réel.
