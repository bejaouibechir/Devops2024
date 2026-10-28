# Exercices GitLab CI/CD — adaptation du parcours Jenkins

## Objectif

Reprendre les huit exercices du [dossier Jenkins](../../2.CICD%20jenkins/readme.md), avec un énoncé et un corrigé séparés pour chacun. Les objectifs sont conservés, les mécanismes sont adaptés.

## Progression

| Énoncé | Compétence | Corrigé |
| --- | --- | --- |
| [Exercice 1](1.Exercice%201.md) | Input et lecture de fichier | [Solution 1](solutions/1.Solution%20Exercice%201.md) |
| [Exercice 2](2.Exercice%202.md) | Configuration et dotenv | [Solution 2](solutions/2.Solution%20Exercice%202.md) |
| [Exercice 3](3.Exercice%203.md) | Réussite et échec | [Solution 3](solutions/3.Solution%20Exercice%203.md) |
| [Exercice 4](4.Exercice%204.md) | Délai et répétition | [Solution 4](solutions/4.Solution%20Exercice%204.md) |
| [Exercice 5](5.Exercice%205.md) | Schedule nocturne | [Solution 5](solutions/5.Solution%20Exercice%205.md) |
| [Exercice 6](6.Exercice%206.md) | Commandes SSH | [Solution 6](solutions/6.Solution%20Exercice%206.md) |
| [Exercice 7](7.Exercice%207.md) | Script distant | [Solution 7](solutions/7.Solution%20Exercice%207.md) |
| [Exercice 8](8.Exercice%208.md) | Ansible depuis le runner | [Solution 8](solutions/8.Solution%20Exercice%208.md) |

## Prérequis communs

- GitLab 18.1 ou ultérieur pour utiliser les inputs de pipeline présentés ici.
- Un projet d'exercice et un runner Linux disponible. Les corrigés ciblent un executor **Docker**, acceptant les jobs sans tags.
- Si votre runner impose des tags, ajoutez-les sous `default: tags`. Avec un executor Shell, `image` n'installe rien : préparez les outils sur l'hôte et adaptez les étapes d'installation.
- Accès aux registres et dépôts de paquets utilisés par les images. Les exercices SSH installent OpenSSH ; le dernier installe aussi Ansible.
- Ne définissez pas de variables de projet ou de lancement portant les mêmes noms que les variables `EXO_...` des corrigés : une priorité supérieure pourrait masquer leur valeur.

Copiez le corrigé de l'exercice choisi dans `.gitlab-ci.yml`, commitez-le et lancez **Build > Pipelines > New pipeline** sur cette branche. Les `workflow:rules` des exercices 1 à 4 autorisent uniquement cette source `web` ; un push du fichier ne lance donc pas l'atelier. L'exercice 5 autorise aussi `schedule`.

Les inputs sont renseignés à la création du pipeline. Les corrigés ne demandent pas une saisie à un shell CI non interactif. [Inputs GitLab](https://docs.gitlab.com/ci/inputs/)

## Prérequis SSH pour les exercices 6 à 8

Préparez une VM Linux d'exercice et un compte SSH dédié. Installez sa clé publique dans `~/.ssh/authorized_keys`. Les diagnostics proposés ne demandent pas de privilèges sudo.

La VM doit être joignable depuis le réseau du runner. Une IP publique n'est pas indispensable si un accès privé autorisé existe. Le compte distant doit disposer de Bash pour l'exercice 7, et de Python 3.9 à 3.14 pour la branche Ansible choisie dans l'exercice 8.

Dans **Settings > CI/CD > Variables**, configurez :

| Nom | Type | Contenu |
| --- | --- | --- |
| `SSH_PRIVATE_KEY` | File | Clé privée dédiée complète, au format LF et terminée par un saut de ligne |
| `SSH_KNOWN_HOSTS` | File | Clés d'hôte obtenues et vérifiées à l'avance |
| `SSH_HOST` | Variable | Nom DNS ou IPv4 de la VM pour ces exemples |
| `SSH_USER` | Variable | Compte Linux distant |
| `SSH_PORT` | Variable | Port numérique, par exemple `22` |

La valeur d'une variable **File** est le chemin du fichier temporaire, pas le texte du secret. Marquez les variables sensibles **Protected**, utilisez une portée d'environnement `*` pour ces diagnostics et lancez depuis une branche protégée, par exemple `main`. Les corrigés 6 à 8 l'exigent aussi dans leurs règles.

La clé multiligne ne satisfait pas les contraintes habituelles de masquage : choisissez la visibilité compatible avec ce format, sans afficher la clé ni activer de trace de commandes sensible. [Préparation des clés SSH](https://docs.gitlab.com/ci/jobs/ssh_keys/), [variables File et Protected](https://docs.gitlab.com/ci/variables/)

Le fichier `SSH_KNOWN_HOSTS` doit correspondre au nom et au port utilisés. Pour un port non standard, prévoir l'entrée `[serveur]:port`. Un `ssh-keyscan` effectué pendant le pipeline ne remplace pas la validation préalable de l'identité du serveur.

## Divergences entre les trois plateformes

| Besoin | Jenkins | GitLab CI/CD dans ces ateliers | GitHub Actions : repère de comparaison |
| --- | --- | --- | --- |
| Nom/cible utilisateur | Paramètre ou `input` en cours de pipeline | `spec:inputs` au lancement | Inputs de `workflow_dispatch` au lancement |
| Configuration calculée partagée | État Groovy/environnement selon portée | Rapport `dotenv` pour les jobs suivants | Outputs de jobs ; `GITHUB_ENV` reste dans un job |
| Choix des branches de traitement | `when` ou logique Groovy | `rules` à la création du pipeline | `if` et dépendances `needs` |
| Actions de fin | `post` | `.post` et `when`, ou `after_script` local | Étapes/jobs conditionnels |
| Deux passages espacés | Logique explicite ; `retry` ne suffit pas | Deux jobs, dont un `delayed` | Orchestration/délai à concevoir, sans équivalent direct de `start_in` |
| Cron | Déclaré dans le pipeline ou le job | Schedule créé dans GitLab | Événement `schedule` du workflow |
| Secret sous forme de fichier | Credential lié à un fichier | Variable de type File | Secret texte à matérialiser dans un fichier |
| Exécution Ansible | CLI sur l'agent | CLI dans le job du runner | CLI dans une étape du runner |

Cette comparaison sert à comprendre les choix GitLab. Le [parcours GitHub Actions](../../4.CICD%20github%20actions/Exercices/readme.md) propose les huit ateliers correspondants avec ses propres corrigés.

## Travail à remettre et validation

Pour chaque exercice, fournir le YAML, les fichiers annexes demandés, le résultat de validation GitLab et les traces utiles sans secrets. Réaliser aussi les essais négatifs décrits.

Les fichiers YAML sont des exemples à intégrer dans votre projet, pas des pipelines exécutés par cette rédaction. Utilisez le [Pipeline editor et CI Lint](https://docs.gitlab.com/ci/yaml/lint/) avec votre version GitLab ; les règles limitant les sources doivent être prises en compte lors d'une simulation de création de pipeline.

Contrôles locaux réussis le 29 octobre 2026, en incluant les README Jenkins et GitLab : 19 fichiers Markdown, 130 liens locaux, 9 configurations YAML, 26 fragments shell et 22 cas simulés. Aucun appel à CI Lint, lancement de pipeline, création de schedule ou accès SSH/Ansible n'a été effectué.
