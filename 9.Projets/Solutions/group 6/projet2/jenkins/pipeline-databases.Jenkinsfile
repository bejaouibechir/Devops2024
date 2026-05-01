// ============================================================
// PIPELINE : Installation des bases de données
// Installe PostgreSQL ET Redis en PARALLÈLE
// Principe Jenkins : parallel{} exécute plusieurs stages en même temps
// ============================================================
pipeline {

    agent any

    // Principe Jenkins : Les parameters permettent de paramétrer l'exécution
    parameters {
        string(name: 'DB_IP',      defaultValue: '', description: 'IP de la machine base de données')
        string(name: 'BACKEND_IP', defaultValue: '', description: 'IP(s) du/des backend(s) — séparés par virgule')
        string(name: 'FRONT_IP',   defaultValue: '', description: 'IP de la machine frontend/Nginx')
        password(name: 'PG_APP_PASSWORD',  defaultValue: '', description: 'Mot de passe PostgreSQL applicatif')
        password(name: 'PG_REPL_PASSWORD', defaultValue: '', description: 'Mot de passe PostgreSQL réplication')
    }

    // Principe Jenkins : environment{} définit des variables disponibles dans tout le pipeline
    environment {
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        ANSIBLE_FORCE_COLOR       = '1'
        INFRA_DIR                 = 'solution/ansible'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Préparer inventaire et secrets') {
            steps {
                // Principe Jenkins : withCredentials masque les secrets dans les logs
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'stockmaster-ssh',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    // Générer l'inventaire dynamiquement avec les IPs passées en paramètres
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
                    }

                    // Générer le fichier de secrets (masqué dans les logs grâce à withCredentials)
                    writeFile file: "${INFRA_DIR}/vars/secrets.yml", text: """
pg_app_password: "${params.PG_APP_PASSWORD}"
pg_repl_password: "${params.PG_REPL_PASSWORD}"
"""
                }
            }
        }

        // Principe Jenkins : parallel{} pour exécuter PostgreSQL et Redis simultanément
        stage('Installer BDD en parallèle') {
            parallel {

                stage('PostgreSQL — Base de données') {
                    steps {
                        sh """
                            cd ${INFRA_DIR}
                            ansible-playbook -i inventory.ini 01-postgres.yml \
                              -e @vars/secrets.yml \
                              --tags install,configure
                        """
                    }
                }

                stage('Redis — Cache (Docker)') {
                    steps {
                        sh """
                            cd ${INFRA_DIR}
                            ansible-playbook -i inventory.ini 02-redis.yml \
                              --tags install,configure
                        """
                    }
                }
            }
        }

        stage('Health checks') {
            steps {
                sh """
                    cd ${INFRA_DIR}
                    ansible-playbook -i inventory.ini 01-postgres.yml --tags healthcheck -e @vars/secrets.yml
                    ansible-playbook -i inventory.ini 02-redis.yml    --tags healthcheck
                """
            }
        }
    }

    // Principe Jenkins : post{} s'exécute à la fin du pipeline, quel que soit le résultat
    post {
        success {
            echo "✅ Base de données opérationnelle — PostgreSQL + Redis prêts"
        }
        failure {
            echo "❌ Echec — Consulter les logs Ansible ci-dessus pour diagnostiquer"
        }
        always {
            // Nettoyer le fichier de secrets du workspace Jenkins
            sh "rm -f ${INFRA_DIR}/vars/secrets.yml || true"
        }
    }
}
