// Définit le pipeline déclaratif piloté par Jenkins.
pipeline {
    // Exécute le pipeline sur un agent Jenkins disponible et éligible.
    agent any

    // Organise les phases du pipeline ; leur ordre est séquentiel hors branches parallèles.
    stages {
        // Ouvre la phase « Checkout », visible séparément dans le suivi du build.
        stage('Checkout') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Permet la logique Groovy : variables locales, conditions et boucles.
                script {
                    // Exécute les opérations dont les exceptions pourront être traitées dans catch.
                    try {
                        git 'https://gitlab.com/ton-utilisateur/ton-projet.git'
                    // Traite l'exception levée dans try et choisit le résultat à conserver.
                    } catch (Exception e) {
                        // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                        echo "Erreur lors du checkout: ${e.message}"
                        // Fixe explicitement le résultat du build dans Jenkins.
                        currentBuild.result = 'FAILURE'
                        // Lève une erreur pour interrompre le traitement et signaler son échec.
                        error("Échec du checkout")
                    }
                }
            }
        }

        // Ouvre la phase « Build », visible séparément dans le suivi du build.
        stage('Build') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Permet la logique Groovy : variables locales, conditions et boucles.
                script {
                    // Exécute les opérations dont les exceptions pourront être traitées dans catch.
                    try {
                        // Lance le cycle Maven demandé ; les résultats de compilation sont produits dans target.
                        sh './mvnw clean package'
                    // Traite l'exception levée dans try et choisit le résultat à conserver.
                    } catch (Exception e) {
                        // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                        echo "Erreur lors de la construction: ${e.message}"
                        // Fixe explicitement le résultat du build dans Jenkins.
                        currentBuild.result = 'FAILURE'
                        // Lève une erreur pour interrompre le traitement et signaler son échec.
                        error("Échec de la construction")
                    }
                }
            }
        }

        // Ouvre la phase « Archive Artifacts », visible séparément dans le suivi du build.
        stage('Archive Artifacts') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Permet la logique Groovy : variables locales, conditions et boucles.
                script {
                    // Exécute les opérations dont les exceptions pourront être traitées dans catch.
                    try {
                        // Archive les fichiers du workspace pour les rendre disponibles après le build.
                        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                    // Traite l'exception levée dans try et choisit le résultat à conserver.
                    } catch (Exception e) {
                        // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                        echo "Erreur lors de l'archivage des artefacts: ${e.message}"
                        // Fixe explicitement le résultat du build dans Jenkins.
                        currentBuild.result = 'FAILURE'
                        // Lève une erreur pour interrompre le traitement et signaler son échec.
                        error("Échec de l'archivage des artefacts")
                    }
                }
            }
        }
    }

    // Regroupe les actions de fin selon le résultat du pipeline ou du stage.
    post {
        // Exécute ce bilan quel que soit le résultat normal de la portée.
        always {
            // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
            echo 'Pipeline terminé.'
        }
        // Exécute ce bilan lorsque la portée a réussi.
        success {
            // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
            echo 'Pipeline exécuté avec succès !'
        }
        // Exécute ce bilan lorsque la portée a échoué.
        failure {
            // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
            echo 'Le pipeline a échoué.'
        }
    }
}
