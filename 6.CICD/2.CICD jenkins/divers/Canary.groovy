// Définit le pipeline déclaratif piloté par Jenkins.
pipeline {
    // Exécute le pipeline sur un agent Jenkins disponible et éligible.
    agent any

    // Déclare les variables d'environnement disponibles dans cette portée du pipeline.
    environment {
        targetEnv = "CANARY"
        env1 = "PROD1"
        env2 = "PROD2"
        env3 = "PROD3"
        env4 = "PROD4"
        CANARY_PERCENTAGE = 25
    }

    // Organise les phases du pipeline ; leur ordre est séquentiel hors branches parallèles.
    stages {
        // Ouvre la phase « SCM », visible séparément dans le suivi du build.
        stage('SCM') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                echo "Clonage du dépôt Git..."
            }
        }

        // Ouvre la phase « Build », visible séparément dans le suivi du build.
        stage('Build') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                echo "Compilation du code..."
            }
        }

        // Ouvre la phase « Deploy Canary », visible séparément dans le suivi du build.
        stage('Deploy Canary') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                echo "Déploiement Canary sur ${env1} (${CANARY_PERCENTAGE}% du trafic)..."
            }
        }

        // Ouvre la phase « Smoke Test Canary », visible séparément dans le suivi du build.
        stage('Smoke Test Canary') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Permet la logique Groovy : variables locales, conditions et boucles.
                script {
                    def testResult = "success"  // Simuler un test (remplace par un vrai check)
                    // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                    echo "Résultat du test sur ${env1}: ${testResult}"
                    // Choisit la branche à exécuter selon cette condition Groovy.
                    if (testResult == "error") {
                        // Lève une erreur pour interrompre le traitement et signaler son échec.
                        error "Échec sur ${env1}, rollback en cours..."
                    }
                }
            }
        }

        // Ouvre la phase « Progressive Rollout », visible séparément dans le suivi du build.
        stage('Progressive Rollout') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Permet la logique Groovy : variables locales, conditions et boucles.
                script {
                    // Prépare une variable Groovy locale pour les calculs ou décisions de ce bloc.
                    def environments = [env2, env3, env4]
                    def percentages = [50, 75, 100]

                    // Parcourt les éléments pour répéter la logique de ce bloc.
                    for (int i = 0; i < environments.size(); i++) {
                        // Prépare une variable Groovy locale pour les calculs ou décisions de ce bloc.
                        def env = environments[i]
                        CANARY_PERCENTAGE = percentages[i]

                        // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                        echo "Déploiement sur ${env} (${CANARY_PERCENTAGE}% du trafic)..."

                        def testResult = "success"  // Simuler un test (remplace par un vrai check)
                        echo "Résultat du test sur ${env}: ${testResult}"

                        // Choisit la branche à exécuter selon cette condition Groovy.
                        if (testResult == "error") {
                            // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                            echo "Rollback sur ${env} et réessai..."
                        } else {
                            echo "Succès sur ${env}, on continue..."
                        }
                    }
                }
            }
        }

        // Ouvre la phase « Finalization », visible séparément dans le suivi du build.
        stage('Finalization') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                echo "Déploiement Canary terminé à 100% sur ${env4}!"
            }
        }
    }
}
