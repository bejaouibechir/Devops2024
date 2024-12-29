### Exercice : Utilisation de `git stash` pour sauvegarder des modifications non terminées

#### Objectif
Apprendre à utiliser `git stash` pour sauvegarder temporairement des modifications locales sans les valider, et les restaurer plus tard.

---

### Étapes de l'exercice :

#### 1. **Création d'un nouveau dépôt de test**
   ```bash
   mkdir git-stash-demo
   cd git-stash-demo
   git init
   ```

#### 2. **Créer un fichier et effectuer une première validation**
   - Créez un fichier nommé `demo.txt` :
     ```bash
     echo "Ligne initiale" > demo.txt
     ```
   - Ajoutez-le au dépôt et validez :
     ```bash
     git add demo.txt
     git commit -m "Ajout de la ligne initiale"
     ```

#### 3. **Effectuer des modifications non terminées**
   - Ajoutez une nouvelle ligne au fichier :
     ```bash
     echo "Modification non terminée" >> demo.txt
     ```

#### 4. **Vérifiez les modifications non validées**
   ```bash
   git status
   git diff
   ```

#### 5. **Sauvegarder les modifications avec `git stash`**
   - Stashez les changements :
     ```bash
     git stash
     ```
   - Vérifiez que le fichier est revenu à l’état précédent :
     ```bash
     git status
     ```

#### 6. **Restaurer les modifications**
   - Listez les stashes :
     ```bash
     git stash list
     ```
   - Appliquez le stash :
     ```bash
     git stash apply
     ```
   - Confirmez que les modifications sont restaurées :
     ```bash
     git diff
     ```

#### 7. **Supprimez le stash**
   - Supprimez le stash après l’avoir appliqué :
     ```bash
     git stash drop
     ```

---

### Étape Bonus : Sauvegarde avec un message personnalisé
   - Ajoutez une nouvelle modification :
     ```bash
     echo "Nouvelle modification" >> demo.txt
     ```
   - Stashez avec un message :
     ```bash
     git stash push -m "Sauvegarde de la nouvelle modification"
     ```
   - Listez les stashes pour voir le message associé :
     ```bash
     git stash list
     ```

---

### Résultat attendu
- Vous avez appris à :
  - Sauvegarder des modifications avec `git stash`.
  - Restaurer des modifications stashez.
  - Nettoyer les stashes inutiles.
