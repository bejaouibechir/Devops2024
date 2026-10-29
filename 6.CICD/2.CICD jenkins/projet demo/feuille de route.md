# Feuille de route duprojet

###  **Exercice Jenkins : Pipeline CI pour un projet Spring Boot**

####  Objectifs

* Créer un pipeline déclaratif Jenkins.
* Compiler un projet Spring Boot avec Maven.
* Exécuter les tests unitaires.
* Générer un artefact `.jar` en sortie.

---

###  Contexte

Vous disposez d’un projet Spring Boot compressé dans `projet demo.zip`.

Le projet contient :

* Un fichier `pom.xml` pour Maven.
* Du code source Java dans `src/main/java/`.
* Des tests unitaires dans `src/test/java/`.

---

###  Travail demandé

1. **Créer un Jenkinsfile** à la racine du projet avec les étapes suivantes :

   * **Étape 1 : Checkout**

     * Cloner le dépôt depuis Git (ou copier le zip en local et le décompresser dans Jenkins si hors Git).

   * **Étape 2 : Build**

     * Utiliser Maven pour compiler le projet.
     * Commande attendue : `mvn clean compile`

   * **Étape 3 : Test**

     * Lancer les tests unitaires.
     * Commande attendue : `mvn test`

   * **Étape 4 : Package**

     * Générer l’artefact `.jar`.
     * Commande attendue : `mvn package`
     * Le `.jar` doit être généré dans le dossier `target/`.

   * **Étape 5 : Archive**

     * Archiver le fichier `.jar` en tant qu’artefact Jenkins.

2. **Exécuter le pipeline** et valider que :

   * La compilation s’effectue sans erreur.
   * Tous les tests passent.
   * Un fichier `.jar` est bien généré et archivé dans Jenkins.

---

###  Exemple de `Jenkinsfile`

```groovy
// Définit le pipeline déclaratif piloté par Jenkins.
pipeline {
    // Exécute le pipeline sur un agent Jenkins disponible et éligible.
    agent any

    tools {
        maven 'Maven 3.8.8'  // Assurez-vous que cet outil est configuré dans Jenkins
        jdk 'Java 17'        // Idem pour le JDK
    }

    // Organise les phases du pipeline ; leur ordre est séquentiel hors branches parallèles.
    stages {
        // Ouvre la phase « Checkout », visible séparément dans le suivi du build.
        stage('Checkout') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Exemple pour projet local :
                echo "Code déjà présent dans le workspace"
            }
        }

        // Ouvre la phase « Build », visible séparément dans le suivi du build.
        stage('Build') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Lance le cycle Maven demandé ; les résultats de compilation sont produits dans target.
                sh 'mvn clean compile'
            }
        }

        // Ouvre la phase « Test », visible séparément dans le suivi du build.
        stage('Test') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Lance les tests Maven ; leur échec est transmis au job.
                sh 'mvn test'
            }
        }

        // Ouvre la phase « Package », visible séparément dans le suivi du build.
        stage('Package') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Lance le cycle Maven demandé ; les résultats de compilation sont produits dans target.
                sh 'mvn package'
            }
        }

        // Ouvre la phase « Archive Artifact », visible séparément dans le suivi du build.
        stage('Archive Artifact') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Archive les fichiers du workspace pour les rendre disponibles après le build.
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }
}
```

---

###  Instructions complémentaires

* Si Jenkins n’a pas Maven ou Java configuré, installez-les via :

  * Jenkins > Manage Jenkins > Global Tool Configuration
* Assurez-vous que `mvn` est disponible dans le PATH si vous n’utilisez pas la directive `tools`.

