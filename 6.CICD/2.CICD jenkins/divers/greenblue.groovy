pipeline {
    agent any
    
     environment {
         targetEnv = "A"
         otherEnv =  "B"
     }

    stages {
        stage('SCM') {
            steps {
                echo "Clonage du dépôt Git..."
            }
        }

         stage('Build') {
            steps {
                echo "Compilation du code"
               
            }
        }
        
        stage('Deploy to Target') {
            steps {
                script {
                    echo "Déploiement sur ${targetEnv}... actuellement green"
                    
                    // Mise à jour de l'environnement actif pour la suite du pipeline
                    sh "echo ${targetEnv} > ~/param"
                    echo "${targetEnv} est actuellement green"
                }
            }
        }

        stage('Smoke Test on Target') {
            steps {
                script {
                    echo "Exécution du Smoke Test sur ${targetEnv}..."
                }
            }
        }
        
        stage('Handle Failure & Redeploy if Needed') {
            steps {
                script {
                    def testResult = sh(script: "cat ~/result", returnStdout: true).trim()
                    if (testResult == "error") {
                        echo "Le Smoke Test a échoué ! Déploiement sur l'autre environnement..."
                        // Redéployer en appelant à nouveau le déploiement
                        sh "echo 'Déploiement en cours sur ${otherEnv}'"
                        echo "Maitenant ${otherEnv} est devenu green et ${targetEnv} est devenu blue"
                        sh 'echo "${otherEnv}" > ~/param'
                    } else {
                        echo "Smoke Test réussi, on continue avec ${targetEnv}  comme green..."
                    }
                }
            }
        }

        stage('Switch Traffic to New Version') {
            steps {
                script {
                    def newEnv = sh(script: "cat ~/param", returnStdout: true).trim()
                    echo "Le ${newEnv} qui est green ..."
                    
                    // Simuler la mise à jour du proxy/load balancer
                    echo " deploiement vers ${newEnv}"
                }
            }
        }

        stage('Cleanup Old Deployment') {
            steps {
                script {
                     def newEnv = sh(script: "cat ~/param", returnStdout: true).trim()
                     def oldEnv = (newEnv=='A')? 'B' : 'A'
                   
                    if(oldEnv == "A")
                    {
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
