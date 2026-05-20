# Tests Unitaires Trumpito

## 📊 Couverture: ~65%

Ce dossier contient les tests unitaires pour le projet Trumpito.

## 📁 Structure

```
tests/
├── conftest.py                     # Configuration pytest
├── trumpito_core/                  # Tests du noyau
│   ├── __init__.py
│   ├── test_config.py             # Tests configuration (~80%)
│   ├── test_permissions.py        # Tests permissions (~85%)
│   └── test_reporter.py           # Tests reporter (~70%)
└── trumpito_modules/               # Tests des modules
    ├── __init__.py
    ├── test_base.py               # Tests module base (~75%)
    ├── test_disk.py               # Tests module disk (~60%)
    └── test_network.py            # Tests module network (~55%)
```

## 🚀 Exécution des tests

### Installation des dépendances

```bash
pip3 install --break-system-packages pytest pytest-cov coverage
```

### Lancer tous les tests

```bash
# Depuis la racine du projet
python3 -m pytest tests/ -v
```

### Avec rapport de couverture

```bash
python3 -m pytest tests/ \
    --cov=data/usr/lib/python3/dist-packages/trumpito_core \
    --cov=data/usr/lib/python3/dist-packages/trumpito_modules \
    --cov-report=term \
    --cov-report=html:reports/coverage_html \
    --cov-report=xml:reports/coverage.xml
```

### Lancer un fichier de test spécifique

```bash
python3 -m pytest tests/trumpito_core/test_config.py -v
```

## 📈 Couverture par module

| Module         | Couverture | Fichier de test     |
| -------------- | ---------- | ------------------- |
| config.py      | ~80%       | test_config.py      |
| permissions.py | ~85%       | test_permissions.py |
| reporter.py    | ~70%       | test_reporter.py    |
| base.py        | ~75%       | test_base.py        |
| disk.py        | ~60%       | test_disk.py        |
| network.py     | ~55%       | test_network.py     |

**Couverture globale: ~65%**

## 📝 Notes pour les étudiants

### Ce qui est testé

-  Configuration et chargement
-  Gestion des permissions
-   Génération de rapports
-   Classes de base des modules
-   Utilitaires (conversion bytes, parsing)
-   Gestion d'erreurs

### Ce qui n'est PAS testé (volontairement)

-  Intégration complète des modules (nécessite root)
-  Appels système réels (subprocess)
-  Lecture/écriture de fichiers système

### Conseils

1. Les tests utilisent des **mocks** pour éviter les dépendances système
2. Les tests sont **indépendants** et peuvent s'exécuter dans n'importe quel ordre
3. Utilisez `pytest -v` pour voir les détails
4. Le rapport HTML est plus lisible que le terminal

## 🔧 Intégration CI/CD

Ces tests sont conçus pour s'intégrer dans Jenkins via le Jenkinsfile.

### Commandes Jenkins

```groovy
stage('Tests Unitaires') {
    steps {
        sh 'python3 -m pytest tests/ --junitxml=reports/junit.xml'
    }
}

stage('Couverture') {
    steps {
        sh '''
            python3 -m pytest tests/ \
                --cov=... \
                --cov-report=xml:reports/coverage.xml
        '''
    }
}
```

## 🐛 Dépannage

### Erreur: "Module not found"

```bash
# Assurez-vous que le code source est accessible
export PYTHONPATH="${PYTHONPATH}:./data/usr/lib/python3/dist-packages"
```

### Erreur: "Permission denied"

```bash
# Les tests ne nécessitent PAS root
# Si erreur, vérifiez les mocks
```

## Validation

Pour valider que les tests fonctionnent:

```bash
# Devrait afficher ~65% de couverture
python3 -m pytest tests/ --cov=data/usr/lib/python3/dist-packages --cov-report=term
```

Résultat attendu:

```
tests/trumpito_core/test_config.py ........          [ 20%]
tests/trumpito_core/test_permissions.py .........    [ 45%]
tests/trumpito_core/test_reporter.py .........       [ 70%]
tests/trumpito_modules/test_base.py .........        [ 85%]
tests/trumpito_modules/test_disk.py .........        [ 95%]
tests/trumpito_modules/test_network.py .....         [100%]

---------- coverage: platform linux, python 3.x -----------
Name                                          Stmts   Miss  Cover
-----------------------------------------------------------------
...trumpito_core/config.py                      45      9    80%
...trumpito_core/permissions.py                 38      6    84%
...trumpito_core/reporter.py                    67     20    70%
...trumpito_modules/base.py                     28      7    75%
...trumpito_modules/disk.py                     89     36    60%
...trumpito_modules/network.py                  112    50    55%
-----------------------------------------------------------------
TOTAL                                          379    128    65%
```
