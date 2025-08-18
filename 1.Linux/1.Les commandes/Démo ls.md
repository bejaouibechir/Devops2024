# Démo Ls

#  Démo continue : `ls` en action

### 1️ Mise en place

```bash
mkdir projet
cd projet
touch fichier1.txt fichier2.log fichier3.c
mkdir dossierA dossierB
touch .cache .config
```

 On a maintenant :

* 3 fichiers (`.txt`, `.log`, `.c`)
* 2 dossiers (`dossierA`, `dossierB`)
* 2 fichiers **cachés** (`.cache`, `.config`)

---

### 2️ Liste simple

```bash
ls
```

 Affiche : `dossierA  dossierB  fichier1.txt  fichier2.log  fichier3.c`

---

### 3️ Affichage détaillé

```bash
ls -l
```

 Donne les **droits, propriétaire, taille, date**.
Exemple :

```
-rw-r--r-- 1 ec2-user ec2-user   0 Aug 18 18:10 fichier1.txt
drwxr-xr-x 2 ec2-user ec2-user  40 Aug 18 18:10 dossierA
```

---

### 4️ Tailles lisibles

```bash
ls -lh
```

 Même que `-l` mais taille en **K, M, G** au lieu d’octets.

---

### 5️ Inclure les fichiers cachés

```bash
ls -lha
```

 Montre aussi `.cache` et `.config`.

---

### 6️ Afficher uniquement les dossiers

```bash
ls -d */
```

 Résultat : `dossierA/  dossierB/`

---

### 7️ Trier par date (récent en dernier)

```bash
ls -ltr
```

 Affiche du plus ancien au plus récent.

---

### 8️ Trier par taille

```bash
ls -lhS
```

 Les fichiers sont classés du plus grand au plus petit.

---

### 9️ Trier par extension

```bash
ls -lX
```

 Classe les fichiers selon `.c`, `.log`, `.txt` …

---

### 10 Afficher récursivement

```bash
ls -lR
```

 Liste aussi le contenu de `dossierA` et `dossierB` (même s’ils sont vides).

---

### 1️1 Ajouter des indicateurs de type

```bash
ls -F
```

 Résultat :

* `dossierA/` (le `/` indique un dossier)
* `fichier3.c` (simple fichier)
* `script.sh*` (si exécutable, un `*` apparaît)

---

### 12 Avec couleurs

```bash
ls --color=auto
```

 Les fichiers sont en blanc, dossiers en bleu, exécutables en vert.

---

### 13 Mélange astucieux : « vue complète »

```bash
ls -lhat --color=auto
```

 Combo puissant :

* `l` → détails complets
* `h` → tailles lisibles
* `a` → inclut cachés
* `t` → tri par date (dernier modifié en premier)
* `--color=auto` → couleurs

---

 Résultat : tu as montré en une seule démo **les options les plus utiles de `ls`** en enchaînant des cas concrets.

---

Veux-tu que je prépare la même démo mais sous forme **script Bash prêt à exécuter** (qui crée, manipule et affiche directement toutes les étapes) pour ton bootcamp Linux ?
