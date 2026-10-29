# Parcours GitLab CI/CD

Ce parcours transpose les thèmes et exercices Jenkins vers GitLab CI/CD en explicitant leurs différences : jobs isolés, inputs de pipeline, règles évaluées avant exécution, artefacts, planification et accès distants.

Les exemples et corrigés comportent des commentaires en français directement dans le YAML et les scripts. Ils expliquent les règles de création du pipeline, la portée des variables, les commandes du runner, les échanges par artefacts et les accès SSH. Les programmes Python et playbooks Ansible générés sont aussi commentés.

Les ajouts ont été comparés au code précédent et contrôlés localement le 29 octobre 2026, sans changement des commandes ni des clés de configuration. Ces vérifications ne remplacent pas CI Lint et l'essai sur votre instance.

## Tutoriels

| Ordre | Article | Objectif |
| --- | --- | --- |
| 0 | [Runners](0.runners.md) | Choisir l'exécuteur et ses tags |
| 1 | [Stages](1.stages.md) | Ordonner les jobs et les étapes |
| 2 | [Environnement et paramètres](2.environnement%20et%20params.md) | Variables, inputs et données calculées |
| 3 | [Post](3.post.md) | `after_script`, `.post` et conditions de résultat |
| 4 | [Options](4.options.md) | Concurrence, reprises, délais et conservation |
| 5 | [Triggers](5.triggers.md) | Sources de pipeline et déclenchements |
| 6 | [Input](6.input.md) | Paramètres et décisions manuelles |
| 7 | [Artefacts](7.artefact.md) | Conservation, transfert et publication |
| 8 | [SSH](8.ssh%20command.md) | Identités, vérification d'hôte et commandes distantes |

## Exercices

Le [guide des exercices](Exercices/readme.md) fournit les prérequis, la progression et les divergences avec Jenkins et GitHub Actions.

| Exercice | Sujet | Corrigé |
| --- | --- | --- |
| [1](Exercices/1.Exercice%201.md) | Input utilisateur et fichier du runner | [Solution 1](Exercices/solutions/1.Solution%20Exercice%201.md) |
| [2](Exercices/2.Exercice%202.md) | Cible dev/staging/prod et rapport dotenv | [Solution 2](Exercices/solutions/2.Solution%20Exercice%202.md) |
| [3](Exercices/3.Exercice%203.md) | Bilan de réussite ou d'échec | [Solution 3](Exercices/solutions/3.Solution%20Exercice%203.md) |
| [4](Exercices/4.Exercice%204.md) | Deux passages avec un job différé | [Solution 4](Exercices/solutions/4.Solution%20Exercice%204.md) |
| [5](Exercices/5.Exercice%205.md) | Pipeline nocturne à 2 h | [Solution 5](Exercices/solutions/5.Solution%20Exercice%205.md) |
| [6](Exercices/6.Exercice%206.md) | Diagnostic distant avec OpenSSH | [Solution 6](Exercices/solutions/6.Solution%20Exercice%206.md) |
| [7](Exercices/7.Exercice%207.md) | Générer, transférer et exécuter un script Bash | [Solution 7](Exercices/solutions/7.Solution%20Exercice%207.md) |
| [8](Exercices/8.Exercice%208.md) | Générer un inventaire et exécuter Ansible | [Solution 8](Exercices/solutions/8.Solution%20Exercice%208.md) |

## Utilisation

Les configurations complètes sont des variantes indépendantes de `.gitlab-ci.yml`, à la racine d'un dépôt d'exercice. N'assemblez pas plusieurs corrigés en répétant `spec`, `workflow` ou `stages`.

Les exercices ciblent GitLab 18.1 ou ultérieur pour les inputs de pipeline. Leur guide précise les besoins du runner, les images et les conditions d'accès aux variables protégées.

Les commandes de déploiement des exercices 2 et 5 sont simulées. Les exercices 6 à 8, une fois configurés et lancés, accèdent réellement à la VM indiquée.

Validez la configuration dans le [Pipeline editor / CI Lint](https://docs.gitlab.com/ci/yaml/lint/), puis comparez les résultats aux critères de chaque énoncé.

## Comparaisons

- [Parcours Jenkins et supports sources](../2.CICD%20jenkins/readme.md).
- [Articles et exercices GitHub Actions](../4.CICD%20github%20actions/README.md).

Les fichiers sont des supports pédagogiques : aucun pipeline GitLab, schedule ni accès à une VM n'a été créé ou exécuté lors de leur rédaction.
