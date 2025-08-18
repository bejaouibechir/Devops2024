# Ajouter et monter un nouveau volume EBS sur EC2 Ubuntu

## 1. Créer un nouveau volume EBS dans AWS

1. Connecte-toi à la **console AWS → EC2 → Volumes**.
2. Clique sur **Create volume**.

   * Type : `gp3` (SSD standard).
   * Taille : par ex. `20 GiB`.
   * Availability Zone : **la même que ta machine EC2** (ex. `us-east-1a`).
3. Clique sur **Create volume**.

 Tu verras ton nouveau volume dans la liste.

---

## 2. Attacher le volume à ton instance

1. Sélectionne ton volume → **Actions → Attach volume**.
2. Choisis ton instance EC2.
3. Laisse le nom du périphérique proposé (`/dev/sdf` ou `/dev/xvdf`).
4. Clique sur **Attach**.

 Côté Linux, il apparaîtra généralement comme `/dev/nvme1n1` (ou `nvme2n1` si tu en avais déjà un autre).

---

## 3. Vérifier le nouveau disque sur ta machine

Sur ton EC2 (via MobaXterm) :

```bash
lsblk
```

Tu devrais voir quelque chose comme :

```
nvme0n1   8G   (disque système déjà monté sur /)
nvme1n1  20G   (nouveau disque, vide, sans partition)
```

---

## 4. Créer une partition sur le disque

 Attention à bien viser le **nouveau disque** (`nvme1n1`).

```bash
sudo fdisk /dev/nvme1n1
```

Dans `fdisk` :

* `n` → nouvelle partition
* `p` → primaire
* \[Entrée] → taille par défaut (tout le disque)
* `w` → écrire et quitter

---

## 5. Formater la partition en ext4

```bash
sudo mkfs -t ext4 /dev/nvme1n1p1
```

---

## 6. Créer un point de montage

```bash
sudo mkdir /data
```

---

## 7. Monter le disque

```bash
sudo mount /dev/nvme1n1p1 /data
```

Vérifie :

```bash
df -h
```

 Tu verras `/dev/nvme1n1p1` monté sur `/data`.

---

## 8. Rendre le montage permanent

Sinon, il disparaît au reboot.

1. Obtenir l’UUID :

   ```bash
   sudo blkid /dev/nvme1n1p1
   ```

   Exemple :

   ```
   UUID="abcd-1234-efgh-5678" TYPE="ext4"
   ```

2. Éditer `/etc/fstab` :

   ```bash
   sudo nano /etc/fstab
   ```

3. Ajouter une ligne :

   ```
   UUID=abcd-1234-efgh-5678   /data   ext4   defaults,nofail   0   2
   ```

4. Tester :

   ```bash
   sudo mount -a
   ```

---

#  Résultat final

* Tu as **créé un volume EBS** de 20 Go.
* Tu l’as **attaché** à ton instance EC2.
* Tu l’as **formaté et monté** dans `/data`.
* Il est **persistant au reboot** via `/etc/fstab`.

