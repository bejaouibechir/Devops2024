#  Différences entre `/bin`, `/sbin`, `/usr/bin`, `/usr/sbin`

### 1. Présentation rapide

* **`/bin`** : commandes de base accessibles à tous les utilisateurs (exécutables essentiels au système et aux utilisateurs).
* **`/sbin`** : commandes système pour l’administration (souvent réservées à root).
* **`/usr/bin`** : la majorité des programmes utilisateur installés.
* **`/usr/sbin`** : programmes administratifs supplémentaires (réservés à root).

---

### 2. Explorer `/bin`

```bash
ls /bin | head -10
```

 Exemples courants :

```
bash
cat
ls
cp
mv
rm
```

 Ce sont des commandes **utilisables par tout le monde**, nécessaires au fonctionnement de base.

---

### 3. Explorer `/sbin`

```bash
ls /sbin | head -10
```

 Exemples :

```
fdisk
mkfs
iptables
reboot
shutdown
```

 Ce sont des outils d’**administration**.
Exemple : `fdisk` permet de gérer les partitions → il faut `sudo`.

---

### 4. Explorer `/usr/bin`

```bash
ls /usr/bin | head -10
```

 Exemples :

```
python3
git
nano
ssh
curl
```

 Ce sont des **logiciels pour les utilisateurs** (pas essentiels au boot).
Exemple : `git` ou `curl` sont utiles, mais le système peut démarrer sans eux.

---

### 5. Explorer `/usr/sbin`

```bash
ls /usr/sbin | head -10
```

 Exemples :

```
apache2
sshd
cron
useradd
groupdel
```

 Ce sont des programmes **administratifs** mais non essentiels au tout premier boot.
Exemple : `apache2` (serveur web) ou `sshd` (daemon SSH).

---

### 6. Petite comparaison pratique

* Tape :

  ```bash
  which ls
  ```

  Résultat → `/bin/ls` → outil de base.

* Tape :

  ```bash
  which fdisk
  ```

  Résultat → `/sbin/fdisk` → réservé à l’admin.

* Tape :

  ```bash
  which git
  ```

  Résultat → `/usr/bin/git` → outil utilisateur.

* Tape :

  ```bash
  which apache2
  ```

  Résultat → `/usr/sbin/apache2` → outil d’administration.

---

# ✅ Résumé visuel

* `/bin` → commandes **essentielles utilisateur** (ls, cp, bash).
* `/sbin` → commandes **essentielles admin/root** (fdisk, reboot).
* `/usr/bin` → **applications et utilitaires** (git, python3, curl).
* `/usr/sbin` → **programmes admin avancés** (apache2, sshd, useradd).

