pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                script {
                    try {
                        git 'https://gitlab.com/ton-utilisateur/ton-projet.git'
                    } catch (Exception e) {
                        echo "Erreur lors du checkout: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Échec du checkout")
                    }
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    try {
                        sh './mvnw clean package'
                    } catch (Exception e) {
                        echo "Erreur lors de la construction: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Échec de la construction")
                    }
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                script {
                    try {
                        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                    } catch (Exception e) {
                        echo "Erreur lors de l'archivage des artefacts: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error("Échec de l'archivage des artefacts")
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline terminé.'
        }
        success {
            echo 'Pipeline exécuté avec succès !'
        }
        failure {
            echo 'Le pipeline a échoué.'
        }
    }
}
