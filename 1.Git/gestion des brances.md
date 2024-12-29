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

### Résultat attendu
- Une compréhension approfondie des branches locales et distantes.
- Maitrise de la gestion des conflits et des fusions.
- Pratique de Git Flow dans un projet réel.
