# Exercices GitHub Actions — parcours comparatif

Huit ateliers reprennent les objectifs des [exercices Jenkins](../../2.CICD%20jenkins/readme.md) et de leur [adaptation GitLab CI](../../3.CICD%20gitlab-ci/Exercices/readme.md). Chaque énoncé possède un corrigé autonome. Le YAML décrit des modèles d'exécution différents : une traduction des noms de clés ne suffit pas.

## Progression

| Énoncé | Sujet | Corrigé |
| --- | --- | --- |
| [Exercice 1](1.Exercice%201.md) | Saisie et fichier | [Solution 1](solutions/1.Solution%20Exercice%201.md) |
| [Exercice 2](2.Exercice%202.md) | Configuration et outputs | [Solution 2](solutions/2.Solution%20Exercice%202.md) |
| [Exercice 3](3.Exercice%203.md) | Réussite, échec et bilan | [Solution 3](solutions/3.Solution%20Exercice%203.md) |
| [Exercice 4](4.Exercice%204.md) | Deux passages et attente | [Solution 4](solutions/4.Solution%20Exercice%204.md) |
| [Exercice 5](5.Exercice%205.md) | Planification nocturne | [Solution 5](solutions/5.Solution%20Exercice%205.md) |
| [Exercice 6](6.Exercice%206.md) | Diagnostics SSH | [Solution 6](solutions/6.Solution%20Exercice%206.md) |
| [Exercice 7](7.Exercice%207.md) | Script, SCP et artefacts | [Solution 7](solutions/7.Solution%20Exercice%207.md) |
| [Exercice 8](8.Exercice%208.md) | Inventaire et playbook Ansible | [Solution 8](solutions/8.Solution%20Exercice%208.md) |

## Préparation et lancement

Utilisez un dépôt d'exercice sur **GitHub.com**, avec Actions autorisé et des runners hébergés `ubuntu-24.04`. Les scripts utilisent Bash. Un runner auto-hébergé nécessite de vérifier ses outils, sa version et son isolation.

Copiez chaque workflow complet dans `.github/workflows/exercice-N.yml`. Plusieurs fichiers peuvent coexister ; ne fusionnez pas leurs clés `on` et `jobs`. Publiez d'abord le fichier sur la branche par défaut, puis choisissez **Actions > nom du workflow > Run workflow**. Un simple push ne déclenche pas les exemples manuels. [Lancement manuel](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow)

Les exemples ciblent les versions vérifiées les 28 et 29 octobre 2026 : [checkout v7](https://github.com/actions/checkout), [upload-artifact v7](https://github.com/actions/upload-artifact) et [setup-python v7](https://github.com/actions/setup-python). Les tags facilitent la lecture ; un SHA complet vérifié permet de figer une action. Vérifiez la compatibilité avant adaptation à GitHub Enterprise Server, notamment pour les artefacts et `schedule.timezone`.

Les exercices 2 et 5 simulent un déploiement : leurs URL sont fictives et aucune base n'est créée. Les exercices 6 à 8 réalisent de vraies connexions à votre VM lorsque vous les lancez.

## Préparation SSH pour les exercices 6 à 8

Préparez une VM Linux joignable depuis le runner, un compte dédié et une clé SSH réservée à l'atelier. Placez sa clé publique dans `~/.ssh/authorized_keys`. Les lectures ne nécessitent pas sudo. La VM doit disposer de Bash pour l'exercice 7 et de `/usr/bin/python3` compatible pour l'exercice 8.

Créez l'environnement GitHub **`atelier-ssh`**, puis ses secrets et variables :

| Emplacement dans l'environnement | Nom | Valeur |
| --- | --- | --- |
| Secret | `SSH_PRIVATE_KEY` | Clé privée complète multiligne, LF, avec saut de ligne final |
| Secret | `SSH_KNOWN_HOSTS` | Clés d'hôte obtenues et vérifiées à l'avance |
| Variable | `SSH_HOST` | DNS ou IPv4 de la VM |
| Variable | `SSH_USER` | Compte Linux dédié |
| Variable | `SSH_PORT` | Port, par exemple `22` |

Pour ces ateliers, utilisez une clé dédiée sans phrase secrète, protégée par l'accès à l'environnement ; la gestion d'un agent SSH avec passphrase serait une autre variante. Les workflows reconstruisent les fichiers dans `$RUNNER_TEMP`, avec des droits restrictifs. GitHub ne fournit pas ici le type de variable **File** de GitLab. [Secrets GitHub](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets)

Réservez l'environnement à la branche `main` et protégez les modifications de cette branche. Les workflows vérifient aussi `refs/heads/main` ; adaptez les deux réglages si votre branche porte un autre nom. Ajoutez des reviewers si votre offre le permet. Les règles et secrets d'environnement exigent de vérifier leur disponibilité selon l'offre et la visibilité du dépôt ; ne remplacez pas silencieusement cette protection par des secrets de dépôt. [Environnements et disponibilité](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments)

`SSH_KNOWN_HOSTS` doit correspondre à l'hôte et au port, notamment `[hote]:port` pour un port non standard. N'utilisez ni `StrictHostKeyChecking=no` ni une collecte non vérifiée pendant le workflow.

## Ce qui change entre les trois outils

| Besoin | Jenkins | GitLab CI | GitHub Actions dans ces ateliers |
| --- | --- | --- | --- |
| Saisie | Paramètre ou `input` en cours d'exécution | `spec:inputs` à la création | `workflow_dispatch.inputs` au lancement |
| Ordre | Stages séquentiels | `stages` et éventuellement `needs` | Jobs indépendants, liens `needs` explicites |
| Configuration entre jobs | Portée Groovy/environnement | Rapport `dotenv` | Output d'étape, output de job, puis `needs` |
| Variable entre étapes | Environnement selon portée | Script du job | Écriture dans `GITHUB_ENV`, disponible aux étapes suivantes |
| Branche de traitement | `when` | `rules`, job éventuellement absent | `if`, job non retenu affiché comme ignoré |
| Traitement final | `post` | `.post`, `when`, `after_script` | Fonctions de statut et `needs.<job>.result` |
| Attente | `sleep` explicite | Job `delayed` avec `start_in` | `sleep` dans le runner pour cet atelier |
| Planification | `triggers` | Schedule créé séparément | Événement `schedule` dans le workflow |
| Fichier secret | Credential/fichier | Variable File | Secret texte à écrire dans un fichier |
| Fichiers archivés | `archiveArtifacts` | `artifacts` | Action `upload-artifact` |

`GITHUB_ENV` ne transmet pas les valeurs à un autre job. Un fichier présent dans un job n'est pas automatiquement présent dans le suivant. Les outputs servent aux petites valeurs non secrètes ; utilisez les artefacts pour les fichiers.

## Livrables et validation

Pour chaque atelier, remettez le workflow, les fichiers demandés, un lien vers les exécutions et les essais négatifs sans divulguer les secrets. Les critères et résultats des corrigés sont des résultats **attendus**, pas la preuve d'une exécution sur votre compte.

Les contrôles locaux de rédaction ne remplacent pas l'interprétation des expressions par GitHub, la disponibilité des runners et des actions, ni un essai réseau. Aucun workflow n'a été publié ou exécuté sur GitHub et aucune VM n'a été contactée pendant la rédaction.

Contrôles réussis le 29 octobre 2026 sur ce parcours et son README parent : 18 fichiers Markdown, 86 liens locaux, 9 blocs YAML dont 8 workflows complets et une étape de retry, 29 fragments shell, 4 fragments Python et un playbook inclus. Les 54 cas locaux couvrent notamment les cibles, les erreurs volontaires, les outputs, le retry et les paramètres d'inventaire.

Pour ces essais locaux, l'attente du retry a été neutralisée et la copie `/tmp/input` redirigée dans un dossier temporaire de contrôle. Aucune validation par le moteur d'expressions GitHub ou par `actionlint`, aucun cron réel et aucune exécution Ansible n'ont été effectués.

[Retour aux articles](../README.md)
