pipeline {
    agent any

    environment {
        APP_NAME = "my-app"
        BLUE_URL = "http://blue.example.com"
        GREEN_URL = "http://green.example.com"
        CURRENT_ENV = sh(script: "curl -s http://proxy.example.com/status", returnStdout: true).trim()
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

        stage('Deploy to Green') {
            steps {
                script {
                    def newEnv = (env.CURRENT_ENV == "blue") ? "green" : "blue"
                    sh "scp target/*.jar user@${newEnv}.example.com:/opt/apps/${APP_NAME}.jar"
                    sh "ssh user@${newEnv}.example.com 'nohup java -jar /opt/apps/${APP_NAME}.jar &'"
                }
            }
        }

        stage('Smoke Test on Green') {
            steps {
                script {
                    def newEnv = (env.CURRENT_ENV == "blue") ? "green" : "blue"
                    sh "curl -f http://${newEnv}.example.com/health || exit 1"
                }
            }
        }

        stage('Switch Traffic to Green') {
            steps {
                script {
                    def newEnv = (env.CURRENT_ENV == "blue") ? "green" : "blue"
                    sh "ssh user@proxy.example.com 'update_proxy.sh ${newEnv}'"
                }
            }
        }

        stage('Cleanup Old Deployment') {
            steps {
                script {
                    def oldEnv = (env.CURRENT_ENV == "blue") ? "blue" : "green"
                    sh "ssh user@${oldEnv}.example.com 'pkill -f ${APP_NAME}.jar'"
                }
            }
        }
    }
}
