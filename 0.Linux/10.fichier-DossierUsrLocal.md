# Démo qui montre l'utilité du dossier /Usr/Local

Voici le **tutoriel généré** en prenant en considération ce qui a été discuté précédemment :

### Objectif :
Compiler et installer un programme **C** simple dans **`/usr/local/bin`** en utilisant un **Makefile**, tout en résolvant les erreurs potentielles liées à des redéfinitions ou des erreurs de syntaxe.

### Étape 1 : Créer le programme C

1. Créez un répertoire de travail, par exemple **`my_project`** :
   ```bash
   mkdir ~/my_project
   cd ~/my_project
   ```

2. Créez un fichier **`hello_world.c`** :
   ```bash
   nano hello_world.c
   ```

3. Insérez le code suivant :
   ```c
   #include <stdio.h>

   int main() {
       printf("Hello, World!\n");
       return 0;
   }
   ```

   - Ce code affiche "Hello, World!" lorsqu'il est exécuté.

4. Sauvegardez et quittez l'éditeur (**Ctrl + X**, puis **Y**, et **Entrée**).

### Étape 2 : Créer le Makefile

1. Créez un fichier **`Makefile`** (nom avec **M majuscule**) dans le même répertoire :
   ```bash
   nano Makefile
   ```

2. Insérez le contenu suivant :

   ```makefile
   # Variables
   CC = gcc
   CFLAGS = -Wall
   TARGET = hello_world

   # Compile le programme
   all: $(TARGET)

   $(TARGET): hello_world.c
       $(CC) $(CFLAGS) -o $(TARGET) hello_world.c

   # Installe le binaire dans /usr/local/bin
   install: $(TARGET)
       sudo cp $(TARGET) /usr/local/bin/

   # Nettoie les fichiers générés
   clean:
       rm -f $(TARGET)

   # Désinstalle le programme
   uninstall:
       sudo rm -f /usr/local/bin/$(TARGET)
   ```

   - **Explication** :
     - **all** : Compile le programme.
     - **install** : Copie le binaire dans **`/usr/local/bin`** pour qu'il soit disponible globalement.
     - **clean** : Supprime les fichiers binaires.
     - **uninstall** : Supprime le programme installé.

3. Sauvegardez et quittez l'éditeur.

### Étape 3 : Compilation et installation

1. **Compiler** le programme :
   - Exécutez la commande suivante dans le répertoire **`my_project`** :
     ```bash
     make
     ```

   - Cette commande va générer un fichier binaire nommé **`hello_world`**.

2. **Installer** le programme dans **`/usr/local/bin`** :
   - Exécutez la commande suivante :
     ```bash
     sudo make install
     ```

   - Cela copie le binaire dans **`/usr/local/bin`**, le rendant disponible pour tous les utilisateurs du système.

3. **Exécuter** le programme installé :
   - Tapez simplement :
     ```bash
     hello_world
     ```

   - Vous devriez voir la sortie suivante :
     ```bash
     Hello, World!
     ```

### Étape 4 : Nettoyage et désinstallation

1. **Nettoyer** les fichiers générés :
   - Pour supprimer le fichier binaire généré dans votre répertoire de travail :
     ```bash
     make clean
     ```

2. **Désinstaller** le programme de **`/usr/local/bin`** :
   - Si vous souhaitez supprimer le programme installé :
     ```bash
     sudo make uninstall
     ```

### Vérification des prérequis

1. Assurez-vous d'avoir installé **gcc** et **make** :
   - **Vérifier gcc** :
     ```bash
     gcc --version
     ```
   - **Vérifier make** :
     ```bash
     make --version
     ```

   - Si ces outils ne sont pas installés, vous pouvez les installer :
     - Pour **Ubuntu/Debian** :
       ```bash
       sudo apt install gcc make
       ```
     - Pour **CentOS/Fedora** :
       ```bash
       sudo yum install gcc make
       ```

Ce tutoriel montre comment **compiler, installer et gérer un programme C** simple en utilisant un **Makefile** et en le plaçant dans **`/usr/local/bin`**
