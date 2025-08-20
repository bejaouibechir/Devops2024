# Le dossier Mnt pour le montage des nouveaux perifériques

Voici un tutoriel complet pour **monter un disque virtuel dans VirtualBox** et l'utiliser sous **Ubuntu 22.04** avec le point de montage **/mnt** :

### Étape 1 : Ajouter un disque dans VirtualBox
   - Ouvrez **VirtualBox**.
   - Sélectionnez votre machine virtuelle et cliquez sur **Paramètres** > **Stockage**.
   - Sous **Contrôleur SATA**, cliquez sur l’icône du disque avec un "+" pour ajouter un disque.
   - Choisissez un disque existant ou créez-en un nouveau (comme **SecondDisque.vdi**).

### Étape 2 : Démarrer la machine virtuelle
   Démarrez la machine virtuelle Ubuntu.

### Étape 3 : Identifier le disque
   Utilisez cette commande pour identifier le nouveau disque ajouté :
   ```bash
   sudo fdisk -l
   ```
   Vous devriez voir un disque non partitionné, comme **/dev/sdb**.

### Étape 4 : Créer une partition sur le disque
   Utilisez **fdisk** pour créer une partition sur le disque :
   ```bash
   sudo fdisk /dev/sdb
   ```
   Suivez ces étapes :
   - Tapez `n` pour créer une nouvelle partition.
   - Acceptez les valeurs par défaut.
   - Tapez `w` pour écrire les modifications.

### Étape 5 : Formater la partition
   Formatez la partition (par exemple **/dev/sdb1**) en **ext4** :
   ```bash
   sudo mkfs.ext4 /dev/sdb1
   ```

### Étape 6 : Monter la partition dans /mnt
   Créez un point de montage, puis montez la partition :
   ```bash
   sudo mkdir /mnt/mydisk
   sudo mount /dev/sdb1 /mnt/mydisk
   ```

### Étape 7 : Vérifier le montage
   Accédez au point de montage et vérifiez son contenu :
   ```bash
   cd /mnt/mydisk
   ls
   ```

### Étape 8 : Rendre le montage permanent (facultatif)
   Pour que le disque soit monté au démarrage, modifiez **/etc/fstab** :
   ```bash
   sudo nano /etc/fstab
   ```
   Ajoutez la ligne suivante :
   ```
   /dev/sdb1  /mnt/mydisk  ext4  defaults  0  2
   ```

### Étape 9 : Démonter le disque
   Une fois que vous avez fini d'utiliser le disque, démontez-le :
   ```bash
   sudo umount /mnt/mydisk
   ```

Cette procédure vous permettra d'ajouter un nouveau disque dans VirtualBox, de le partitionner, le formater, et l'utiliser efficacement sous **Ubuntu 22.04**.
