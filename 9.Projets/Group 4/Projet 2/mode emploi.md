# 📟 COMMANDES TRUMPITO

## Youtube

https://studio.youtube.com/video/owY92uYVTRQ/edit

## Commandes principales

```bash
# Afficher la version
trumpito --version

# Afficher l'aide
trumpito --help

# Scan complet du système
sudo trumpito scan

# Générer un rapport détaillé
sudo trumpito report

# Sans la bannière
trumpito scan --no-banner
```

## Gestion des modules

```bash
# Lister les modules disponibles
trumpito module list

# Exécuter un module spécifique
sudo trumpito module run disk
sudo trumpito module run network
sudo trumpito module run services
sudo trumpito module run packages
```

## Options de sortie

```bash
# Format texte (par défaut)
sudo trumpito scan --format text

# Format JSON
sudo trumpito scan --format json

# Exporter vers un fichier
sudo trumpito scan --output /tmp/rapport.txt
sudo trumpito report --format json --output /tmp/rapport.json
```

## Exemples complets

```bash
# Rapport JSON sauvegardé
sudo trumpito report --format json --output ~/audit-$(date +%Y%m%d).json

# Scan sans bannière en JSON
sudo trumpito scan --no-banner --format json

# Analyse réseau uniquement
sudo trumpito module run network --format text
```

---

**Note:** Toutes les commandes de scan nécessitent `sudo` (droits root) ! 🔐
