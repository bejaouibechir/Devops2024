# Déchlenchement via scheduler

### 1. Création de Tâches Planifiées (Schedules) dans GitLab
Les **tâches planifiées** (schedules) permettent d’exécuter des pipelines à des intervalles réguliers, comme des tests de régression ou des backups. Voici les étapes pour créer une tâche planifiée :

1. **Accédez à votre projet GitLab** et naviguez vers **CI/CD > Schedules** dans le menu de gauche.
2. Cliquez sur **New schedule** pour créer une nouvelle tâche planifiée.
3. **Configurez la planification** :
   - **Description** : Donnez un nom descriptif à votre tâche (ex : "Daily Regression Tests").
   - **Intervalle (Cron)** : Définissez l'horaire en syntaxe Cron. Par exemple :
     - `0 0 * * *` : tous les jours à minuit.
     - `0 */6 * * *` : toutes les 6 heures.
   - **Target Branch** : Sélectionnez la branche sur laquelle le pipeline sera exécuté.
4. Cliquez sur **Save pipeline schedule** pour enregistrer.

Exemple de configuration `.gitlab-ci.yml` pour les tâches planifiées :
```yaml

stages:
  - test

test_on_schedule:
  stage: test
  script:
    - echo "Le temps d'execution de cette ligne $(date) "
 
  only:
    - schedules


```


