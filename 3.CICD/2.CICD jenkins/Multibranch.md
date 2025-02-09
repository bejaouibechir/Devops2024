### Tutoriel : Multibranch Pipeline Jenkins avec GitLab (détection Merge Request)

---

### 1️⃣ Prérequis
- Jenkins installé avec les plugins nécessaires :
  - GitLab Plugin
  - Multibranch Pipeline
- GitLab Token configuré avec les scopes : `read_repository` et `write_repository` (si push est requis).
- Dépôt GitLab avec branches `main` et `dev`.

---

### 2️⃣ Étapes de Configuration

#### A. Créez le projet GitLab
1. Créez un nouveau dépôt nommé `jenkins-demo`.
2. Initialisez une branche `dev` depuis `main` :
   ```bash
   git checkout -b dev
   git push origin dev
   ```

---

#### B. Ajoutez un Jenkinsfile
Ajoutez le fichier suivant à la racine des branches `main` et `dev` :

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo "Building project..."
            }
        }
        stage('Test') {
            steps {
                echo "Running tests..."
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
```

Commitez le fichier sur les deux branches :
```bash
git add Jenkinsfile
git commit -m "Add Jenkinsfile"
git push origin main
git checkout dev
git merge main
git push origin dev
```

---

#### C. Configurez le Multibranch Pipeline Jenkins
1. Créez un nouveau Multibranch Pipeline dans Jenkins.
2. Configurez les sources :
   - Définissez l’URL du dépôt : `https://gitlab.com/<user>/jenkins-demo.git`.
   - Ajoutez les credentials contenant le token GitLab.
3. Activez le scan périodique des branches :
   - Cochez "Scan Multibranch Pipeline Triggers".
   - Définissez l’intervalle à deux minutes.
4. Sauvegardez la configuration.

---

### 3️⃣ Test avec une Merge Request
1. Créez une Merge Request sur GitLab :
   - Branche source : `dev`.
   - Branche cible : `main`.
2. Patientez le temps du scan (deux minutes).
3. Jenkins détecte automatiquement la Merge Request et déclenche le pipeline.

---

### 4️⃣ Affichez le Stage View
1. Accédez à la branche ou Merge Request dans Jenkins.
2. Consultez le "Full Stage View" pour visualiser les étapes du pipeline.

---

### Résultat attendu
- Jenkins détecte et exécute automatiquement les pipelines pour les branches et les Merge Requests.
- Les étapes du pipeline sont visibles dans le Stage View avec les durées et les résultats. 

--- 

Le Multibranch Pipeline est maintenant opérationnel.