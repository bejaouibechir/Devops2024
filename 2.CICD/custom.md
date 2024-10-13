## Déclenchement via un Webhook pour Triggers Personnalisés
Pour déclencher un pipeline GitLab CI via un **webhook**, suivez ces étapes :

#### A. Créer un Trigger dans GitLab
1. Dans votre projet GitLab, allez dans **Settings > CI/CD**.
2. Sous **Pipeline triggers**, cliquez sur **Add trigger**.
3. Donnez un **nom** à votre trigger et cliquez sur **Add trigger**. Cela génère un **token** unique.
4. **Copiez l’URL** fournie, qui sera de la forme suivante :
   ```
   https://gitlab.com/api/v4/projects/PROJECT_ID/trigger/pipeline?token=TRIGGER_TOKEN&ref=branch_name
   ```
   Remplacez `PROJECT_ID`, `TRIGGER_TOKEN`, et `branch_name` avec les valeurs appropriées.

   **Note: Il est important de lancer la requête en mode POST et non pas GET**

#### B. Exécution du Webhook
Pour déclencher ce pipeline via un webhook (par exemple, depuis un script ou une application), effectuez une requête HTTP `POST` à l’URL copiée. Voici un exemple avec **curl** :
```bash
curl -X POST \
     -F token=TRIGGER_TOKEN \
     -F ref=main \
     https://gitlab.com/api/v4/projects/PROJECT_ID/trigger/pipeline
```

Ou encore via Postman

``` bash
https://gitlab.com/api/v4/projects/projet_id/trigger/pipeline?token=token_value&ref=main    
```





#### Exemple `.gitlab-ci.yml` pour Triggers Personnalisés
Ce job s'exécute uniquement lorsque le pipeline est déclenché via l'API :
```yaml
stages:
  - test

test_on_custom_trigger:
  stage: test
  script:
    - echo "Running tests on custom trigger"
    - npm install
    - npm test
  only:
    - triggers
```
