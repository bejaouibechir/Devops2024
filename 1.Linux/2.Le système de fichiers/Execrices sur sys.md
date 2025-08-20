# Démo sur le dossier sys

#  1. Rôle de `/sys`

Le dossier **`/sys`** est une **interface du noyau Linux** appelée **sysfs**.
Il expose des informations **en temps réel** sur le **matériel** et les **périphériques** de la machine : CPU, mémoire, disques, réseau, USB, pilotes, etc.

* C’est un **pseudo-système de fichiers** (comme `/proc`).
* Tout est dynamique : les fichiers reflètent **l’état actuel** du système.
* Utilisé par **udev**, **systemd** et des outils comme `lsusb`, `lspci`, `hwinfo`.

---

#  2. Structure générale de `/sys`

Voici les sous-dossiers les plus importants :

| Dossier         | Contenu                             | Exemple concret              |
| --------------- | ----------------------------------- | ---------------------------- |
| `/sys/block`    | Infos sur les disques et partitions | `nvme0n1`, `sda`             |
| `/sys/class`    | Périphériques regroupés par type    | `net`, `power_supply`, `tty` |
| `/sys/devices`  | Topologie matérielle complète       | CPU, USB, PCI                |
| `/sys/firmware` | Infos BIOS/UEFI                     | tables ACPI                  |
| `/sys/kernel`   | Paramètres du noyau                 | scheduler, modules           |
| `/sys/module`   | Liste des modules chargés           | `nvme`, `xfs`                |

---

# 🔹 3. Démos concrètes

## **Démo 1 — Explorer les disques avec `/sys/block`**

```bash
ls /sys/block
```

**Résultat attendu :**

```
loop0  loop1  nvme0n1  nvme1n1
```

Chaque entrée = un périphérique bloc (disque, volume EBS, etc.).

Pour voir la **taille** d’un disque :

```bash
cat /sys/block/nvme0n1/size
```

Cela retourne un nombre de **blocs**. Pour le convertir en Gio :

```bash
echo "$(( $(cat /sys/block/nvme0n1/size) * 512 / 1024 / 1024 / 1024 )) Gio"
```

---

## **Démo 2 — Infos réseau via `/sys/class/net`**

Lister les interfaces :

```bash
ls /sys/class/net
```

Exemple de sortie :

```
eth0  lo
```

Vérifier l’état de l’interface :

```bash
cat /sys/class/net/eth0/operstate
```

Vérifier sa vitesse :

```bash
cat /sys/class/net/eth0/speed
```

---

## **Démo 3 — Infos CPU en direct**

Voir tous les cœurs CPU :

```bash
ls /sys/devices/system/cpu | grep cpu
```

Exemple de sortie :

```
cpu0  cpu1  cpu2  cpu3
```

Lire la fréquence actuelle du CPU0 :

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
```

Le résultat est en **kHz** → conversion en MHz :

```bash
echo "$(( $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq) / 1000 )) MHz"
```

---

## **Démo 4 — Infos sur les pilotes chargés**

Lister tous les modules actifs :

```bash
ls /sys/module | head -20
```

Vérifier où le module `nvme` est utilisé :

```bash
ls /sys/module/nvme
```

Voir les périphériques associés :

```bash
ls /sys/module/nvme/drivers
```

---

## **Démo 5 — État des périphériques USB**

```bash
ls /sys/bus/usb/devices
```

Voir l’ID d’un périphérique USB précis :

```bash
cat /sys/bus/usb/devices/usb1/idVendor
cat /sys/bus/usb/devices/usb1/idProduct
```

---

# 4. Cas pratique : mini tableau de bord matériel

On peut combiner plusieurs infos utiles via `/sys` :

```bash
echo "=== CPU ==="
grep . /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq | awk -F: '{printf "%s : %.0f MHz\n", $1, $2/1000}'

echo "=== Disques ==="
for d in $(ls /sys/block/nvme*); do
  echo "$(basename $d): $(( $(cat $d/size) * 512 / 1024 / 1024 / 1024 )) Gio"
done

echo "=== Réseau ==="
for i in $(ls /sys/class/net); do
  echo "$i → état: $(cat /sys/class/net/$i/operstate)"
done
```

---

#  5. Différence `/sys` vs `/proc`

| Aspect  | `/sys`                                 | `/proc`                          |
| ------- | -------------------------------------- | -------------------------------- |
| Contenu | Infos **matériel / périphériques**     | Infos **processus / noyau**      |
| Utilité | Configurer le noyau, gérer les devices | Inspecter les processus          |
| Exemple | `/sys/block`, `/sys/class/net`         | `/proc/cpuinfo`, `/proc/meminfo` |




Veux-tu ?
