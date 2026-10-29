// Définit le pipeline déclaratif piloté par Jenkins.
pipeline {
    // Exécute le pipeline sur un agent Jenkins disponible et éligible.
    agent any
    
     // Déclare les variables d'environnement disponibles dans cette portée du pipeline.
     environment {
         targetEnv = "A"
         otherEnv =  "B"
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
                echo "Compilation du code"
               
            }
        }
        
        // Ouvre la phase « Deploy to Target », visible séparément dans le suivi du build.
        stage('Deploy to Target') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Permet la logique Groovy : variables locales, conditions et boucles.
                script {
                    // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                    echo "Déploiement sur ${targetEnv}... actuellement green"
                    
                    // Mise à jour de l'environnement actif pour la suite du pipeline
                    sh "echo ${targetEnv} > ~/param"
                    echo "${targetEnv} est actuellement green"
                }
            }
        }

        // Ouvre la phase « Smoke Test on Target », visible séparément dans le suivi du build.
        stage('Smoke Test on Target') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Permet la logique Groovy : variables locales, conditions et boucles.
                script {
                    // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                    echo "Exécution du Smoke Test sur ${targetEnv}..."
                }
            }
        }
        
        // Ouvre la phase « Handle Failure & Redeploy if Needed », visible séparément dans le suivi du build.
        stage('Handle Failure & Redeploy if Needed') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Permet la logique Groovy : variables locales, conditions et boucles.
                script {
                    // Exécute la commande sur l'agent et capture sa sortie texte dans la variable locale.
                    def testResult = sh(script: "cat ~/result", returnStdout: true).trim()
                    // Choisit la branche à exécuter selon cette condition Groovy.
                    if (testResult == "error") {
                        // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                        echo "Le Smoke Test a échoué ! Déploiement sur l'autre environnement..."
                        // Redéployer en appelant à nouveau le déploiement
                        sh "echo 'Déploiement en cours sur ${otherEnv}'"
                        echo "Maitenant ${otherEnv} est devenu green et ${targetEnv} est devenu blue"
                        // Exécute cette commande shell sur l'agent Jenkins.
                        sh 'echo "${otherEnv}" > ~/param'
                    } else {
                        // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                        echo "Smoke Test réussi, on continue avec ${targetEnv}  comme green..."
                    }
                }
            }
        }

        // Ouvre la phase « Switch Traffic to New Version », visible séparément dans le suivi du build.
        stage('Switch Traffic to New Version') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Permet la logique Groovy : variables locales, conditions et boucles.
                script {
                    // Exécute la commande sur l'agent et capture sa sortie texte dans la variable locale.
                    def newEnv = sh(script: "cat ~/param", returnStdout: true).trim()
                    // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                    echo "Le ${newEnv} qui est green ..."
                    
                    // Simuler la mise à jour du proxy/load balancer
                    echo " deploiement vers ${newEnv}"
                }
            }
        }

        // Ouvre la phase « Cleanup Old Deployment », visible séparément dans le suivi du build.
        stage('Cleanup Old Deployment') {
            // Regroupe les actions exécutées dans cette phase.
            steps {
                // Permet la logique Groovy : variables locales, conditions et boucles.
                script {
                     // Exécute la commande sur l'agent et capture sa sortie texte dans la variable locale.
                     def newEnv = sh(script: "cat ~/param", returnStdout: true).trim()
                     // Prépare une variable Groovy locale pour les calculs ou décisions de ce bloc.
                     def oldEnv = (newEnv=='A')? 'B' : 'A'
                   
                    // Choisit la branche à exécuter selon cette condition Groovy.
                    if(oldEnv == "A")
                    {
                       // Écrit un message dans la console Jenkins ; ce message seul ne réalise pas l'opération annoncée.
                       echo "Arrêt et nettoyage de l'ancien environnement A"
                    }
                    else
                    {
                        echo "Arrêt et nettoyage de l'ancien environnement B"
                    }
                    
                    // Simuler l'arrêt de l'ancienne version
                    echo " arret du ${oldEnv}"
                }
            }
        }
    }
}
