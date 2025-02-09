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

