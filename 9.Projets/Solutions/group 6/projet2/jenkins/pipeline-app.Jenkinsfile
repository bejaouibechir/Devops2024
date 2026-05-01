// ============================================================
// PIPELINE : Build + Déploiement de l'application (Backend + Frontend)
// Inclut les tests Newman (API Postman) après déploiement backend
// Principe Jenkins : les stages Build s'exécutent en parallèle (Maven + npm)
// ============================================================
pipeline {

    agent any

    parameters {
        string(name: 'DB_IP',      defaultValue: '', description: 'IP de la base de données (pour setenv.sh)')
        string(name: 'BACKEND_IP', defaultValue: '', description: 'IP(s) backend — séparés par virgule')
        string(name: 'FRONT_IP',   defaultValue: '', description: 'IP frontend/Nginx')
        password(name: 'PG_APP_PASSWORD', defaultValue: '', description: 'Mot de passe PostgreSQL applicatif')
        booleanParam(name: 'RUN_NEWMAN', defaultValue: true, description: 'Lancer les tests Newman après déploiement ?')
    }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        ANSIBLE_FORCE_COLOR       = '1'
        INFRA_DIR                 = 'solution/ansible'
        // L'URL de base pour Newman — pointe vers le premier backend
        NEWMAN_BASE_URL           = "http://${params.BACKEND_IP?.split(',')[0]?.trim()}:8080/stockmaster/api"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // Principe Jenkins : parallel{} — Maven et npm buildent en même temps
        stage('Build (parallèle)') {
            parallel {

                stage('Build WAR — Maven') {
                    steps {
                        sh 'cd backend && mvn -DskipTests -Pprod clean package'
                        // Vérifier que le WAR a bien été produit
                        sh 'ls -lh backend/target/stockmaster-backend-1.0.0.war'
                    }
                }

                stage('Build Frontend — npm') {
                    steps {
                        // VITE_API_URL injecté à la compilation pour pointer vers Nginx
                        sh """
                            cd frontend
                            npm ci
                            VITE_API_URL=http://${params.FRONT_IP}/api npm run build
                        """
                        sh 'ls frontend/dist/index.html'
                    }
                }
            }
        }

        stage('Préparer inventaire') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'stockmaster-ssh',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    script {
                        def backendHosts = params.BACKEND_IP.split(',').withIndex().collect { ip, i ->
                            "back${i+1} ansible_host=${ip.trim()} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_KEY}"
                        }.join('\n')

                        writeFile file: "${INFRA_DIR}/inventory.ini", text: """
[db]
db1 ansible_host=${params.DB_IP} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_KEY}

[backend]
${backendHosts}

[frontend]
front1 ansible_host=${params.FRONT_IP} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_KEY}

[all:vars]
ansible_python_interpreter=/usr/bin/python3
"""
                        writeFile file: "${INFRA_DIR}/vars/secrets.yml", text: """
pg_app_password: "${params.PG_APP_PASSWORD}"
"""
                    }
                }
            }
        }

        stage('Déployer Tomcat (infra)') {
            steps {
                sh """
                    cd ${INFRA_DIR}
                    ansible-playbook -i inventory.ini 03-tomcat.yml \
                      -e @vars/secrets.yml \
                      --tags install,configure
                """
            }
        }

        // Principe Jenkins : les deux déploiements peuvent se faire en parallèle
        stage('Déployer application (parallèle)') {
            parallel {

                stage('Déployer WAR Backend') {
                    steps {
                        sh """
                            cd ${INFRA_DIR}
                            ansible-playbook -i inventory.ini 04-backend-deploy.yml \
                              -e @vars/secrets.yml \
                              -e backend_war_src=${WORKSPACE}/backend/target/stockmaster-backend-1.0.0.war
                        """
                    }
                }

                stage('Déployer Frontend + Nginx') {
                    steps {
                        sh """
                            cd ${INFRA_DIR}
                            ansible-playbook -i inventory.ini 05-frontend-nginx.yml \
                              -e frontend_dist_src=${WORKSPACE}/frontend/dist
                        """
                    }
                }
            }
        }

        // Principe Jenkins : when{} conditionne l'exécution d'un stage
        stage('Tests Newman (API)') {
            when {
                expression { return params.RUN_NEWMAN == true }
            }
            steps {
                // Installer Newman si absent
                sh 'npm list -g newman 2>/dev/null || npm install -g newman'

                // Lancer la collection Postman via Newman
                sh """
                    newman run solution/postman/stockmaster-newman.json \
                      --env-var "base_url=${NEWMAN_BASE_URL}" \
                      --reporters cli,junit \
                      --reporter-junit-export newman-results.xml \
                      --bail
                """
            }
            post {
                always {
                    // Publier le rapport JUnit dans Jenkins
                    junit allowEmptyResults: true, testResults: 'newman-results.xml'
                }
            }
        }
    }

    post {
        success {
            echo "✅ Application déployée — http://${params.FRONT_IP}/"
            echo "   Login : admin / Admin123!"
        }
        failure {
            echo "❌ Echec du déploiement — vérifier les logs ci-dessus"
        }
        always {
            sh "rm -f ${INFRA_DIR}/vars/secrets.yml || true"
        }
    }
}
