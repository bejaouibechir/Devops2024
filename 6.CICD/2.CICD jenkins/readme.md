# Parcours Jenkins

Ce dossier regroupe les tutoriels Jenkins, huit exercices avec corrigés et des supports complémentaires. Le parcours suit les thèmes du pipeline déclaratif, puis leur mise en pratique.

Les exemples comportent des commentaires en français directement dans le code : `//` pour Groovy, `#` pour les scripts shell et `<!-- ... -->` pour XML. Ils expliquent l'agent, l'ordre des stages, les conditions, les variables, les commandes et les traitements de fin. Les scripts générés, notamment Bash et Ansible, sont également commentés.

Les ajouts ont été comparés au code précédent et contrôlés localement le 29 octobre 2026. Ils ne constituent pas une validation par Jenkins : les exemples historiques et leurs paramètres à remplacer gardent les limites indiquées ci-dessous.

## Tutoriels

| Ordre | Article | Objectif |
| --- | --- | --- |
| 0 | [Agents](0.agents.md) | Choisir où les commandes s'exécutent |
| 1 | [Stages](1.stages.md) | Organiser les étapes et le parallélisme |
| 2 | [Environnement et paramètres](2.envionement%20et%20params.md) | Définir la configuration et les choix utilisateur |
| 3 | [Post](3.post.md) | Réagir à la réussite et à l'échec |
| 4 | [Options](4.options.md) | Régler concurrence, délais, rétention et reprises |
| 5 | [Triggers](5.triggers.md) | Déclencher par événement ou planification |
| 6 | [Input](6.input.md) | Introduire une décision humaine |
| 7 | [Artefacts](7.artefact.md) | Conserver et transférer les livrables |
| 8 | [SSH](8.ssh%20command.md) | Exécuter des commandes à distance |

## Exercices et corrigés

| Exercice | Thème | Corrigé |
| --- | --- | --- |
| [1](Exercices/1.Exercice%201.md) | Nom fourni par l'utilisateur et lecture d'un fichier | [Solution 1](Exercices/solutions/1.Solutions%20Exercice%201.md) |
| [2](Exercices/2.Exercice%202.md) | Configuration selon dev, staging ou prod | [Solution 2](Exercices/solutions/2.Solutions%20Exercice%202.md) |
| [3](Exercices/3.Exercice%20.3.md) | Actions après succès ou échec | [Solution 3](Exercices/solutions/3.Solutions%20Exercice%203.md) |
| [4](Exercices/4.Exercice%204.md) | Deux exécutions et intervalle d'attente | [Solution 4](Exercices/solutions/4.Solution%20Exercice%204.md) |
| [5](Exercices/5.Exercice%205.md) | Exécution nocturne et configuration de cible | [Solution 5](Exercices/solutions/5.Solution%20Exercice%205.md) |
| [6](Exercices/6.Exercice%206.md) | Commandes SSH sur une VM | [Solution 6](Exercices/solutions/6.Solution%20Exercice%206.md) |
| [7](Exercices/7.Exercice%207.md) | Génération, transfert et exécution d'un script | [Solution 7](Exercices/solutions/7.Solution%20Exercice%207.md) |
| [8](Exercices/8.Exercice%208.md) | Collecte d'informations avec Ansible | [Solution 8](Exercices/solutions/8.Solution%20Exercice%208.md) |

Commencez par l'énoncé, préparez votre pipeline, puis comparez avec le corrigé. Les noms de fichiers historiques sont conservés.

## Prérequis et points d'attention

- Une instance Jenkins accessible et un agent adapté aux commandes proposées.
- Les outils nécessaires sur l'agent : shell, Git, Maven, client SSH ou Ansible selon l'exercice.
- Des credentials dédiés et un serveur d'exercice pour les ateliers distants.
- Une vérification des plugins réellement employés : `sshagent` relève de **SSH Agent**, tandis que `sshCommand` et `sshPut` relèvent de **SSH Pipeline Steps**. [SSH Agent](https://plugins.jenkins.io/ssh-agent/), [SSH Pipeline Steps](https://plugins.jenkins.io/ssh-steps/)

Les corrigés existants sont des supports à examiner, pas une garantie d'exécution immédiate. En particulier :

- `retry(2)` ne programme pas deux passages réussis espacés d'une minute ; `timeout` est une limite de durée, pas une attente.
- Le corrigé 5 doit être complété par une planification et un choix non interactif pour répondre à l'exécution nocturne demandée.
- Les variantes SSH utilisant `allowAnyHosts: true` ou `StrictHostKeyChecking=no` doivent être remplacées par une vérification des clés d'hôte.
- Les simples diagnostics `date`, `whoami`, `hostname`, `uptime` et `df` ne nécessitent généralement pas de compte sudoer.

La [référence du pipeline Jenkins](https://www.jenkins.io/doc/book/pipeline/syntax/) précise les conditions et la portée de chaque directive.

## Supports complémentaires

- [Projet Spring Boot : feuille de route](projet%20demo/feuille%20de%20route.md) et [code source](projet%20demo/code%20source/pom.xml).
- [Multibranch](divers/Multibranch.md), [folders](divers/Folder.md).
- [Publication Nexus](divers/10.nexus%20delivery.md), [SonarQube](divers/12.sonarqube.md).
- [Gestion des exceptions](divers/9.try%20catch.groovy), [canary](divers/Canary.groovy), [blue/green](divers/greenblue.groovy).

## Comparer les plateformes

Consultez les [tutoriels et exercices GitLab CI/CD](../3.CICD%20gitlab-ci/readme.md) et les [articles et exercices GitHub Actions](../4.CICD%20github%20actions/README.md). Les correspondances portent sur les objectifs : les syntaxes, les moments de saisie et les contextes d'exécution ne sont pas interchangeables.
