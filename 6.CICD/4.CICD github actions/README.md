# Parcours GitHub Actions

Cette collection reprend les neuf thèmes des supports Jenkins et GitLab CI/CD, puis consacre une fiche à chaque mécanisme GitHub complémentaire.

Les exemples et corrigés comportent des commentaires en français dans le YAML, les scripts et les fichiers d'action. Ils expliquent les événements, les conditions, les permissions, la circulation des outputs, les commandes et les fichiers produits. Les scripts générés et les playbooks Ansible sont également commentés.

Les notions de matrice, cache, OIDC, réutilisation et environnement existent aussi dans GitLab. Les fiches expliquent leurs particularités GitHub ; elles ne prétendent pas que tous ces concepts sont exclusifs à GitHub.

## 1. Les neuf thèmes communs

| Fiche | Sujet |
| --- | --- |
| [0. Runners](0.runners.md) | Choisir la machine et le conteneur d'exécution |
| [1. Stages](1.stages.md) | Jobs, étapes, dépendances et parallélisme |
| [2. Environnement et paramètres](2.environnement%20et%20params.md) | `env`, `vars`, `secrets`, inputs et outputs |
| [3. Post](3.post.md) | Réussite, échec, bilan et nettoyage |
| [4. Options](4.options.md) | Concurrence, file, timeout, rétention et relance |
| [5. Triggers](5.triggers.md) | Push, PR, planification et chaînage |
| [6. Input](6.input.md) | Paramétrage et approbation manuelle |
| [7. Artefacts](7.artefact.md) | Conservation, transfert, Maven et provenance |
| [8. SSH](8.ssh%20command.md) | Clés, commande distante et SCP |

## 2. Thèmes complémentaires GitHub Actions

| Fiche | Particularité étudiée |
| --- | --- |
| [9. Actions et Marketplace](9.actions%20et%20marketplace.md) | Appel `uses`, contrat d'action et versions |
| [10. Actions composites](10.actions%20personnalisees.md) | `action.yml`, assemblage d'étapes et outputs |
| [11. Workflows réutilisables](11.workflows%20reutilisables.md) | `workflow_call`, contrats et appels entre dépôts |
| [12. Contextes et expressions](12.contextes%20et%20expressions.md) | `${{ }}`, conditions et calendrier d'évaluation |
| [13. Matrices](13.matrices.md) | `strategy.matrix`, variantes et politiques d'échec |
| [14. GITHUB_TOKEN](14.github%20token%20et%20permissions.md) | Identité automatique et permissions |
| [15. OIDC](15.oidc.md) | Claims GitHub et accès temporaires |
| [16. Environnements et protections](16.environnements%20et%20protections.md) | Reviewers, branches, secrets et concurrence |
| [17. Événements GitHub](17.evenements%20github.md) | Issues, releases, dispatch et merge queue |
| [18. Checks, annotations et résumés](18.checks%20annotations%20et%20resumes.md) | Résultats dans l'interface et règles de fusion |
| [19. Cache](19.cache.md) | Clés, restauration et distinction avec les artefacts |
| [20. Attestations](20.attestations.md) | Preuve de provenance et vérification |
| [21. Actions JavaScript](21.actions%20javascript.md) | Runtime Node, inputs et distribution |
| [22. Actions Docker](22.actions%20docker.md) | Métadonnées, image et point d'entrée |

## 3. Mode d'emploi

Le [parcours d'exercices](Exercices/readme.md) propose huit énoncés et huit corrigés : inputs, configuration, bilans, attente, planification, SSH, SCP et Ansible. Chaque atelier explique les divergences avec Jenkins et GitLab CI.

Les blocs annoncés comme workflows complets sont à placer dans `.github/workflows/` d'un dépôt d'exercice. Les fragments ne sont pas des workflows autonomes. Les variantes indépendantes ne doivent pas être fusionnées en répétant les clés `on` ou `jobs`.

Pour un lancement manuel, le workflow doit d'abord exister sur la branche par défaut. Les actions locales nécessitent les fichiers indiqués et un checkout. Les exemples Maven, SSH et OIDC précisent leurs prérequis externes.

Les commandes de build et de déploiement marquées « simulation » ne réalisent pas une compilation ou une livraison réelle.

## 4. Versions et disponibilité

Documentation officielle consultée le 28 octobre 2026. La cible est GitHub.com avec des runners à jour. Les exemples utilisent les versions d'actions documentées lors de la rédaction : checkout v7, setup-java v6, upload-artifact v7, download-artifact v8, cache v6 et attest v4.

Les tags rendent les exemples lisibles ; pour figer une dépendance, utiliser un SHA complet vérifié et organiser ses mises à jour. Les fonctionnalités récentes, dont `concurrency.queue`, `schedule.timezone` et certains formats OIDC, doivent être vérifiées sur GitHub Enterprise Server.

Les limites d'offre pour reviewers, environnements privés et attestations sont signalées dans leurs fiches et reliées aux références officielles.

## 5. État de validation

Contrôles locaux effectués : structure Markdown, encodage UTF-8, 52 liens internes, syntaxe de 80 extraits shell, d'un programme JavaScript et d'un fragment XML. Ces contrôles n'exécutent pas les commandes des ateliers.

Les 53 blocs YAML des articles ont aussi été parsés lors de l'ajout des commentaires le 29 octobre 2026. La comparaison avec le code précédent confirme la conservation des clés, valeurs et commandes, hors commentaires ajoutés. Les fragments et workflows doivent encore être validés dans leur contexte d'intégration par GitHub Actions.

Le parcours d'exercices ajouté ensuite a fait l'objet de contrôles distincts : ses 9 blocs YAML ont été parsés, 29 fragments shell vérifiés et 54 cas simulés localement. Les limites précises sont indiquées dans son guide ; ces contrôles ne constituent pas une exécution sur GitHub.

Les documents sont des supports pédagogiques accompagnés de résultats attendus. Aucun workflow n'a été poussé ou exécuté sur GitHub, aucun serveur SSH contacté et aucune ressource cloud créée dans le cadre de la rédaction.

Les références officielles sont placées auprès des explications correspondantes dans chaque article.
