# Des exercices sur les commandes basiques sous Linux Ubuntu 
---

### **Exercice 1 : Naviguer dans les répertoires et explorer la structure**
- **Objectif** : Explorer la structure du système de fichiers avec les commandes `cd`, `pwd` et `ls`.
- **Instructions** : 
  1. Utilisez `pwd` pour afficher votre répertoire actuel.
  2. Changez de répertoire avec `cd /etc` et utilisez `ls` pour afficher son contenu.
  3. Revenez au répertoire précédent avec `cd -`.
  4. Montez de deux niveaux dans l'arborescence avec `cd ../..`.

---

### **Exercice 2 : Créer une arborescence de répertoires imbriqués**
- **Objectif** : Utiliser `mkdir` pour créer des répertoires imbriqués.
- **Instructions** : 
  1. Créez une arborescence de répertoires avec `mkdir -p ~/Documents/Projets/Exercice1`.
  2. Vérifiez la création avec `ls -R ~/Documents`.

---

### **Exercice 3 : Copier et déplacer des dossiers et des fichiers**
- **Objectif** : Manipuler des fichiers et des répertoires avec `cp` et `mv`.
- **Instructions** : 
  1. Créez un fichier avec `touch ~/Documents/Projets/Exercice1/fichier.txt`.
  2. Copiez ce fichier dans un nouveau répertoire avec `cp ~/Documents/Projets/Exercice1/fichier.txt ~/Documents/Backup/`.
  3. Déplacez ce fichier dans un autre répertoire avec `mv ~/Documents/Backup/fichier.txt ~/Documents/Projets/Exercice2/`.

---

### **Exercice 4 : Créer, vider et supprimer des fichiers**
- **Objectif** : Utiliser `touch`, `truncate`, `rm` pour créer, vider et supprimer des fichiers.
- **Instructions** : 
  1. Créez un fichier vide avec `touch ~/Documents/Projets/fichier_vide.txt`.
  2. Ajoutez du contenu à ce fichier avec `echo "Contenu de test" >> ~/Documents/Projets/fichier_vide.txt`.
  3. Videz le fichier avec `truncate -s 0 ~/Documents/Projets/fichier_vide.txt`.
  4. Supprimez le fichier avec `rm ~/Documents/Projets/fichier_vide.txt`.

---

### **Exercice 5 : Utiliser l'historique avec l'ajout de timestamps**
- **Objectif** : Utiliser l'historique des commandes avec `history` et ajouter des timestamps.
- **Instructions** : 
  1. Ajoutez l'option suivante à votre fichier **bashrc** pour activer les timestamps :  
     ```bash
     echo 'HISTTIMEFORMAT="%Y-%m-%d %T "' >> ~/.bashrc
     ```
  2. Rechargez votre **bashrc** avec `source ~/.bashrc`.
  3. Affichez l'historique des commandes avec `history`.

---

### **Exercice 6 : Comparer deux fichiers texte**
- **Objectif** : Comparer deux fichiers avec `diff` et `cmp`.
- **Instructions** : 
  1. Créez deux fichiers avec `touch fichier1.txt fichier2.txt`.
  2. Ajoutez du contenu dans chaque fichier avec `echo "ligne 1" > fichier1.txt` et `echo "ligne 2" > fichier2.txt`.
  3. Comparez les fichiers avec `diff fichier1.txt fichier2.txt`.
  4. Utilisez `cmp fichier1.txt fichier2.txt` pour afficher les différences de contenu.

---

### **Exercice 7 : Supprimer des répertoires vides et non vides**
- **Objectif** : Utiliser `rmdir` et `rm -rf` pour supprimer des répertoires.
- **Instructions** : 
  1. Créez un répertoire vide avec `mkdir ~/Documents/Vide`.
  2. Supprimez-le avec `rmdir ~/Documents/Vide`.
  3. Créez un répertoire avec des fichiers avec `mkdir -p ~/Documents/NonVide && touch ~/Documents/NonVide/fichier.txt`.
  4. Supprimez-le avec `rm -rf ~/Documents/NonVide`.

---

### **Exercice 8 : Afficher le contenu d'un fichier avec `cat`, `head`, et `tail`**
- **Objectif** : Manipuler l'affichage des fichiers avec `cat`, `head`, et `tail`.
- **Instructions** : 
  1. Créez un fichier avec plusieurs lignes :  
     ```bash
     for i in {1..20}; do echo "ligne $i" >> fichier.txt; done
     ```
  2. Affichez tout le contenu du fichier avec `cat fichier.txt`.
  3. Affichez les 5 premières lignes avec `head -n 5 fichier.txt`.
  4. Affichez les 5 dernières lignes avec `tail -n 5 fichier.txt`.
  5. Utilisez `tail -f fichier.txt` pour suivre en direct les nouvelles lignes ajoutées.

---

### **Exercice 9 : Zipper et dézipper des fichiers**
- **Objectif** : Utiliser `zip` et `unzip` pour compresser et décompresser des fichiers.
- **Instructions** : 
  1. Créez quelques fichiers avec `touch fichier1.txt fichier2.txt fichier3.txt`.
  2. Compressez-les dans une archive zip avec `zip fichiers.zip fichier1.txt fichier2.txt fichier3.txt`.
  3. Décompressez l'archive avec `unzip fichiers.zip`.

---

### **Exercice 10 : Utiliser `tar` pour créer et extraire une archive**
- **Objectif** : Utiliser `tar` pour créer et extraire une archive.
- **Instructions** : 
  1. Créez un répertoire avec des fichiers :  
     ```bash
     mkdir MonProjet && touch MonProjet/{fichier1.txt,fichier2.txt}
     ```
  2. Compressez ce répertoire avec `tar cvf mon_projet.tar MonProjet/`.
  3. Extrayez l'archive avec `tar xvf mon_projet.tar`.

---

### **Exercice 11 : Télécharger des fichiers avec `wget`**
- **Objectif** : Utiliser `wget` pour télécharger un fichier depuis Internet.
- **Instructions** : 
  1. Utilisez la commande `wget` pour télécharger un fichier :  
     ```bash
     wget https://example.com/fichier.zip
     ```
  2. Vérifiez le téléchargement avec `ls`.

---

### **Exercice 12 : Trouver l'emplacement d'une commande avec `whereis`**
- **Objectif** : Utiliser `whereis` pour localiser un fichier binaire, source, ou manuel.
- **Instructions** : 
  1. Utilisez `whereis` pour trouver l'emplacement de la commande **bash** :
     ```bash
     whereis bash
     ```

---

### **Exercice 13 : Créer une sauvegarde avec `cp -r`**
- **Objectif** : Copier un répertoire avec `cp -r` pour créer une sauvegarde.
- **Instructions** : 
  1. Créez un répertoire avec du contenu :  
     ```bash
     mkdir MonDossier && touch MonDossier/fichier{1..3}.txt
     ```
  2. Copiez-le de manière récursive avec `cp -r MonDossier/ Sauvegarde_MonDossier/`.

---

### **Exercice 14 : Supprimer plusieurs fichiers avec un seul `rm`**
- **Objectif** : Supprimer plusieurs fichiers à la fois avec `rm`.
- **Instructions** : 
  1. Créez plusieurs fichiers avec :  
     ```bash
     touch fichier1.txt fichier2.txt fichier3.txt
     ```
  2. Supprimez-les tous d'un coup avec `rm fichier1.txt fichier2.txt fichier3.txt`.

---

### **Exercice 15 : Raccourci pour exécuter la dernière commande**
- **Objectif** : Utiliser `!!` pour exécuter la dernière commande.
- **Instructions** : 
  1. Exécutez une commande simple, par exemple `ls`.
  2. Ré-exécutez la dernière commande avec `!!`.

---

### **Exercice 16 : Afficher et suivre un fichier log en temps réel avec `tail -f`**
- **Objectif** : Utiliser `tail -f` pour suivre un fichier log en temps réel.
- **Instructions** : 
  1. Utilisez `tail -f` sur un fichier journal, par exemple :  
     ```bash
     tail -f /var/log/syslog
     ```

---

### **Exercice 17 : Renommer plusieurs fichiers avec `mv`**
- **Objectif** : Renommer des fichiers en utilisant des commandes combinées avec `mv`.
- **Instructions** : 
  1. Créez trois fichiers :  
     ```bash
     touch fichierA.txt fichierB.txt fichierC.txt
     ```
  2. Renommez

-les avec :  
     ```bash
     mv fichierA.txt nouveauFichierA.txt
     ```

---

### **Exercice 18 : Afficher des fichiers compressés avec `zcat`**
- **Objectif** : Afficher le contenu d'un fichier compressé sans le décompresser avec `zcat`.
- **Instructions** : 
  1. Compressez un fichier texte avec `gzip fichier.txt`.
  2. Affichez son contenu avec `zcat fichier.txt.gz`.

---

### **Exercice 19 : Supprimer un fichier de manière forcée avec `rm -rf`**
- **Objectif** : Utiliser `rm -rf` pour forcer la suppression d'un répertoire non vide.
- **Instructions** : 
  1. Créez un répertoire avec des fichiers :  
     ```bash
     mkdir TestDir && touch TestDir/file{1..3}.txt
     ```
  2. Supprimez-le avec la commande :  
     ```bash
     rm -rf TestDir
     ```

---

### **Exercice 20 : Utiliser `history` pour rejouer des commandes**
- **Objectif** : Utiliser `history` pour revoir et réexécuter des commandes.
- **Instructions** : 
  1. Affichez l'historique des commandes avec `history`.
  2. Exécutez la commande numéro 15 (par exemple) avec :  
     ```bash
     !15
     ```

---

Ces exercices sont conçus pour être variés, intuitifs, et progressifs, tout en explorant des combinaisons utiles de commandes sous Ubuntu. Vous pouvez ajuster le niveau de difficulté selon les participants.
