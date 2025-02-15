pipeline {
    agent any

    environment {
        APP_NAME = "my-app"
        CANARY_PERCENTAGE = 10
        PROD_URL = "http://prod.example.com"
        CANARY_URL = "http://canary.example.com"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://gitlab.com/vadimaentreprise/remoteproject.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Deploy Canary') {
            steps {
                script {
                    echo " Déploiement Canary sur ${CANARY_PERCENTAGE}% du trafic"
                    sh "scp target/*.jar user@canary.example.com:/opt/apps/${APP_NAME}.jar"
                    sh "ssh user@canary.example.com 'nohup java -jar /opt/apps/${APP_NAME}.jar &'"
                }
            }
        }

        stage('Monitor Canary') {
            steps {
                script {
                    def result = sh(script: "curl -f ${CANARY_URL}/health || exit 1", returnStatus: true)
                    if (result != 0) {
                        error " Canary a échoué, rollback en cours..."
                    }
                }
            }
        }

        stage('Gradual Rollout') {
            steps {
                script {
                    def percentages = [25, 50, 75, 100]
                    for (p in percentages) {
                        echo "🚀 Augmentation du Canary à ${p}%"
                        sh "ssh user@proxy.example.com 'update_proxy.sh canary ${p}'"
                        sleep 60  // Pause pour monitoring entre chaque étape
                    }
                }
            }
        }

        stage('Full Rollout or Rollback') {
            steps {
                script {
                    def finalCheck = sh(script: "curl -f ${PROD_URL}/health || exit 1", returnStatus: true)
                    if (finalCheck == 0) {
                        echo " Déploiement réussi sur 100% des utilisateurs !"
                    } else {
                        echo " Erreur détectée ! Rollback en cours..."
                        sh "ssh user@proxy.example.com 'update_proxy.sh rollback'"
                        sh "ssh user@canary.example.com 'pkill -f ${APP_NAME}.jar'"
                    }
                }
            }
        }
    }
}
