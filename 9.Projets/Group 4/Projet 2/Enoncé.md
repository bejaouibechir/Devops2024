# 📚 PROJET DevOps - CI/CD avec Jenkins & Ansible

## Déploiement automatisé de l'application Trumpito

---

## 🎯 OBJECTIFS DU PROJET

Ce projet weekend (10h) vous permettra de maîtriser :

- Configuration d'un pipeline CI/CD avec Jenkins
- Intégration de SonarQube pour l'analyse de code
- Tests unitaires et couverture de code Python
- Déploiement automatisé avec Ansible
- Stratégie Blue/Green deployment

---

## PRÉREQUIS

### Machines nécessaires

- **Machine Jenkins** : 2 CPU, 4GB RAM, Ubuntu 22.04
- **Machine Cible** : 1 CPU, 2GB RAM, Ubuntu 22.04
- **Accès SSH** configuré entre les machines

### Connaissances requises

- Base Linux (commandes, systemd)
- Git basique (clone, commit, push)
- Notions Docker
- Python basique

---

## ARCHITECTURE DU PROJET

```
┌─────────────────────────────────────────────────────────────┐
│                     GITLAB REPOSITORY                        │
│                   (Code Source Trumpito)                     │
└──────────────────────┬──────────────────────────────────────┘
                       │ Webhook / Poll
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    JENKINS SERVER                            │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Pipeline CI/CD                                        │   │
│  │  1. Checkout code                                     │   │
│  │  2. Linting (SonarQube)                              │   │
│  │  3. Tests unitaires                                   │   │
│  │  4. Analyse couverture                                │   │
│  │  5. Analyse sécurité (Bandit)                        │   │
│  │  6. Build .deb                                        │   │
│  │  7. Deploy via Ansible                                │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────────────┘
                       │ Ansible SSH
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    MACHINE CIBLE                             │
│  - Trumpito installé et configuré                           │
│  - Service systemd actif                                     │
└─────────────────────────────────────────────────────────────┘
```

---

## PARTIE I - PIPELINE CI/CD CLASSIQUE

### Durée estimée : 7 heures

---

## 🔧 ÉTAPE 1 : Installation de SonarQube (Docker)

### 1.1 Prérequis sur la machine Jenkins

```bash
# Installation Docker
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker jenkins
sudo usermod -aG docker $USER
```

### 1.2 Déploiement SonarQube

Créer `docker-compose.yml` dans `/opt/sonarqube/` :

```yaml
version: "3"

services:
  sonarqube:
    image: sonarqube:10.3-community
    container_name: sonarqube
    restart: unless-stopped
    environment:
      - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
    ports:
      - "9000:9000"
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
```

**Démarrage :**

```bash
cd /opt/sonarqube
sudo docker-compose up -d

# Attendre le démarrage (2-3 minutes)
sudo docker logs -f sonarqube
```

### 1.3 Configuration SonarQube

1. Accéder à `http://<jenkins-ip>:9000`
2. Credentials par défaut : `admin` / `admin`
3. Changer le mot de passe
4. Créer un projet :
   - **Project key** : `trumpito`
   - **Display name** : `Trumpito DevOps Project`
5. Générer un token :
   - Administration → Security → Users → Tokens
   - Nom : `jenkins-token`
   - **Copier le token** (vous en aurez besoin)

### 1.4 Configuration Jenkins pour SonarQube

**Installer les plugins Jenkins :**

- SonarQube Scanner
- Pipeline
- Ansible
- Git

**Configurer SonarQube dans Jenkins :**

1. Manage Jenkins → Configure System

2. Section "SonarQube servers" :
   
   - Name : `SonarQube`
   - Server URL : `http://localhost:9000`
   - Server authentication token : (ajouter le token via Credentials)

3. Manage Jenkins → Global Tool Configuration

4. Section "SonarQube Scanner" :
   
   - Name : `SonarScanner`
   - Install automatically ✓

---

## ÉTAPE 2 : Installation des outils de test Python

### 2.1 Sur la machine Jenkins

```bash
# Installation Python et outils
sudo apt install -y python3 python3-pip python3-venv

# Installation des outils de test et qualité
sudo pip3 install --break-system-packages \
    pytest \
    pytest-cov \
    coverage \
    bandit \
    pylint \
    black \
    flake8
```

---

## ÉTAPE 3 : Configuration SSH pour Ansible

### 3.1 Génération de clés SSH (sur Jenkins)

```bash
# En tant qu'utilisateur jenkins
sudo su - jenkins
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Copier la clé publique vers la machine cible
ssh-copy-id user@<machine-cible-ip>

# Tester la connexion
ssh user@<machine-cible-ip> "echo 'SSH OK'"
exit
```

### 3.2 Configuration Ansible

Créer `/etc/ansible/ansible.cfg` :

```ini
[defaults]
inventory = /etc/ansible/hosts
host_key_checking = False
remote_user = ubuntu
private_key_file = /var/lib/jenkins/.ssh/id_rsa

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```

Créer `/etc/ansible/hosts` :

```ini
[trumpito_servers]
production ansible_host=<IP_MACHINE_CIBLE> ansible_user=ubuntu

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

**Tester :**

```bash
ansible all -m ping
```

---

## 📝 ÉTAPE 4 : Jenkinsfile - Pipeline CI/CD Classique

Créer `Jenkinsfile` à la racine du projet :

```groovy
pipeline {
    agent any

    environment {
        PROJECT_NAME = 'trumpito'
        VERSION = '1.0.0-1'
        SONAR_PROJECT_KEY = 'trumpito'
        TARGET_HOST = '192.168.1.100' // À modifier selon votre IP
    }

    stages {
        stage(' Checkout') {
            steps {
                echo '=== Récupération du code source ==='
                checkout scm
                sh 'ls -la'
            }
        }

        stage('🧹 Linting - SonarQube') {
            steps {
                echo '=== Analyse de code avec SonarQube ==='
                script {
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv('SonarQube') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                -Dsonar.sources=data/usr/lib/python3/dist-packages \
                                -Dsonar.python.version=3.10 \
                                -Dsonar.language=py
                        """
                    }
                }
            }
        }

        stage('⏳ Quality Gate') {
            steps {
                echo '=== Vérification Quality Gate ==='
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
                }
            }
        }

        stage('🧪 Tests Unitaires') {
            steps {
                echo '=== Exécution des tests unitaires ==='
                sh '''
                    python3 -m pytest tests/ \
                        --verbose \
                        --junitxml=reports/junit.xml \
                        --cov=data/usr/lib/python3/dist-packages/trumpito_core \
                        --cov=data/usr/lib/python3/dist-packages/trumpito_modules \
                        --cov-report=xml:reports/coverage.xml \
                        --cov-report=html:reports/coverage_html \
                        --cov-report=term
                '''
            }
        }

        stage('📊 Analyse de Couverture') {
            steps {
                echo '=== Analyse de la couverture de code ==='
                sh '''
                    python3 -m coverage report
                    python3 -m coverage html -d reports/coverage_html
                '''

                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'reports/coverage_html',
                    reportFiles: 'index.html',
                    reportName: 'Coverage Report'
                ])
            }
        }

        stage('🔒 Analyse de Sécurité') {
            steps {
                echo '=== Analyse de sécurité avec Bandit ==='
                sh '''
                    python3 -m bandit -r data/usr/lib/python3/dist-packages \
                        -f json -o reports/bandit-report.json || true
                    python3 -m bandit -r data/usr/lib/python3/dist-packages \
                        -f txt -o reports/bandit-report.txt || true

                    echo "=== Rapport de sécurité ==="
                    cat reports/bandit-report.txt
                '''

                archiveArtifacts artifacts: 'reports/bandit-report.*', allowEmptyArchive: true
            }
        }

        stage('📦 Build Package .deb') {
            steps {
                echo '=== Construction du paquet Debian ==='
                sh '''
                    # Créer la structure du paquet
                    mkdir -p build/trumpito_${VERSION}_all/DEBIAN

                    # Copier les fichiers de contrôle
                    cp control/control build/trumpito_${VERSION}_all/DEBIAN/
                    cp control/postinst build/trumpito_${VERSION}_all/DEBIAN/
                    cp control/prerm build/trumpito_${VERSION}_all/DEBIAN/
                    cp control/postrm build/trumpito_${VERSION}_all/DEBIAN/

                    # Copier les données
                    cp -r data/* build/trumpito_${VERSION}_all/

                    # Rendre les scripts exécutables
                    chmod 755 build/trumpito_${VERSION}_all/DEBIAN/postinst
                    chmod 755 build/trumpito_${VERSION}_all/DEBIAN/prerm
                    chmod 755 build/trumpito_${VERSION}_all/DEBIAN/postrm
                    chmod 755 build/trumpito_${VERSION}_all/usr/bin/trumpito

                    # Construire le .deb
                    dpkg-deb --build build/trumpito_${VERSION}_all

                    # Vérifier
                    ls -lh build/*.deb
                    dpkg-deb -I build/trumpito_${VERSION}_all.deb
                '''

                archiveArtifacts artifacts: 'build/*.deb', fingerprint: true
            }
        }

        stage('🚀 Déploiement avec Ansible') {
            steps {
                echo '=== Déploiement sur la machine cible ==='
                ansiblePlaybook(
                    playbook: 'ansible/deploy.yml',
                    inventory: '/etc/ansible/hosts',
                    extras: "-e 'deb_file=${WORKSPACE}/build/trumpito_${VERSION}_all.deb'",
                    colorized: true
                )
            }
        }

        stage('  Vérification Post-Déploiement') {
            steps {
                echo '=== Vérification du déploiement ==='
                ansiblePlaybook(
                    playbook: 'ansible/verify.yml',
                    inventory: '/etc/ansible/hosts',
                    colorized: true
                )
            }
        }
    }

    post {
        always {
            echo '=== Nettoyage ==='
            junit 'reports/junit.xml'
            cleanWs()
        }
        success {
            echo '  Pipeline terminé avec succès !'
        }
        failure {
            echo '  Pipeline échoué. Vérifiez les logs.'
        }
    }
}
```

---

## ÉTAPE 5 : Playbooks Ansible

### 5.1 Playbook de déploiement - `ansible/deploy.yml`

```yaml
---
- name: Déploiement de Trumpito
  hosts: trumpito_servers
  become: yes

  vars:
    app_name: trumpito
    app_version: "1.0.0-1"

  tasks:
    - name:  Afficher les informations du déploiement
      debug:
        msg: "Déploiement de {{ app_name }} version {{ app_version }}"

    - name:  Copier le paquet .deb vers la cible
      copy:
        src: "{{ deb_file }}"
        dest: "/tmp/{{ app_name }}_{{ app_version }}_all.deb"
        mode: '0644'

    - name:  Vérifier si l'ancienne version est installée
      command: dpkg -l {{ app_name }}
      register: trumpito_installed
      failed_when: false
      changed_when: false

    - name:  Arrêter le service si déjà installé
      systemd:
        name: "{{ app_name }}.timer"
        state: stopped
        enabled: no
      when: trumpito_installed.rc == 0
      ignore_errors: yes

    - name: Désinstaller l'ancienne version
      apt:
        name: "{{ app_name }}"
        state: absent
        purge: yes
      when: trumpito_installed.rc == 0

    - name: ⚙️ Installer le nouveau paquet
      apt:
        deb: "/tmp/{{ app_name }}_{{ app_version }}_all.deb"
        state: present

    - name:  Recharger les daemons systemd
      systemd:
        daemon_reload: yes

    - name:   Activer le service (optionnel)
      systemd:
        name: "{{ app_name }}.timer"
        enabled: no
        state: stopped
      # Note: timer désactivé par défaut, activation manuelle si besoin

    - name:  Tester l'exécution de Trumpito
      command: trumpito --version
      register: version_check
      changed_when: false

    - name:  Afficher la version installée
      debug:
        var: version_check.stdout_lines

    - name:  Nettoyer le fichier .deb temporaire
      file:
        path: "/tmp/{{ app_name }}_{{ app_version }}_all.deb"
        state: absent
```

### 5.2 Playbook de vérification - `ansible/verify.yml`

```yaml
---
- name: Vérification post-déploiement Trumpito
  hosts: trumpito_servers
  become: yes

  vars:
    app_name: trumpito

  tasks:
    - name:  Vérifier que le paquet est installé
      command: dpkg -l {{ app_name }}
      register: package_check
      failed_when: package_check.rc != 0
      changed_when: false

    - name:   Vérifier les répertoires de configuration
      stat:
        path: "{{ item }}"
      register: dir_checks
      loop:
        - /etc/trumpito
        - /var/log/trumpito
        - /var/lib/trumpito
        - /var/lib/trumpito/reports
      failed_when: not dir_checks.results[0].stat.exists

    - name:  Vérifier le fichier de configuration
      stat:
        path: /etc/trumpito/trumpito.conf
      register: config_file
      failed_when: not config_file.stat.exists

    - name:  Vérifier le binaire
      stat:
        path: /usr/bin/trumpito
      register: binary_file
      failed_when: not binary_file.stat.exists or not binary_file.stat.executable

    - name:  Vérifier les services systemd
      stat:
        path: "{{ item }}"
      register: service_checks
      loop:
        - /lib/systemd/system/trumpito.service
        - /lib/systemd/system/trumpito.timer
      failed_when: not service_checks.results[0].stat.exists

    - name:  Tester l'exécution
      command: trumpito --version
      register: exec_test
      changed_when: false

    - name:   Afficher le résultat du test
      debug:
        msg: "Trumpito fonctionne correctement : {{ exec_test.stdout }}"

    - name:  Générer un rapport de test
      command: trumpito scan --no-banner
      register: scan_test
      changed_when: false
      failed_when: false

    - name: 📝 Sauvegarder le rapport de vérification
      copy:
        content: |
          ========================================
          RAPPORT DE VÉRIFICATION TRUMPITO
          ========================================
          Date: {{ ansible_date_time.iso8601 }}
          Host: {{ inventory_hostname }}

            Paquet installé
            Configuration présente
            Binaire exécutable
            Services systemd créés
            Tests d'exécution réussis

          Version: {{ exec_test.stdout }}
          ========================================
        dest: /tmp/trumpito_verification_report.txt

    - name: 📥 Récupérer le rapport
      fetch:
        src: /tmp/trumpito_verification_report.txt
        dest: "{{ playbook_dir }}/../reports/verification_{{ inventory_hostname }}.txt"
        flat: yes
```

# Documents

### **Tests Unitaires** (~65% de couverture)

2. **trumpito_tests.zip** - Contient :
   - `tests/trumpito_core/` (test_config.py, test_permissions.py, test_reporter.py)
   - `tests/trumpito_modules/` (test_base.py, test_disk.py, test_network.py)
   - README.md avec explications
   - Configuration pytest

### **Partie I - Pipeline Classique**

3. **Jenkinsfile** - Pipeline complet avec :
   
   - Checkout code
   - Analyse SonarQube
   - Tests unitaires
   - Analyse couverture
   - Analyse sécurité (Bandit)
   - Build .deb
   - Déploiement Ansible
   - Vérification

4. **ansible/deploy.yml** - Déploiement standard

5. **ansible/verify.yml** - Vérification post-déploiement

### **Partie II - Blue/Green Deployment**

6. **Jenkinsfile.bluegreen** - Pipeline amélioré avec :
   
   - Détection automatique de la couleur active
   - Déploiement sur environnement inactif
   - Tests de smoke
   - Basculement avec confirmation
   - Script de rollback automatique

7. **ansible/deploy_bluegreen.yml** - Déploiement Blue/Green

8. **ansible/switch_bluegreen.yml** - Basculement du trafic

9. **ansible/smoke_test.yml** - Tests de smoke automatisés

---

## **Instructions :**

1. **Récupérer le code Trumpito** depuis votre GitLab
2. **Extraire trumpito_tests.zip** dans le dossier `tests/`
3. **Placer les fichiers Ansible** dans `ansible/`
4. **Placer le Jenkinsfile** à la racine
5. **Suivre l'énoncé** étape par étape

---

## **Ce qu'on va apprendre :**

- Installation et configuration SonarQube (Docker)
- Intégration Jenkins complète
- Tests unitaires Python (pytest)
- Analyse de couverture de code
- Analyse de sécurité (Bandit)
- Construction de paquets Debian
- Déploiement automatisé avec Ansible
- Stratégie Blue/Green deployment
- Rollback automatique

---

**Partie I:**

- 1h : SonarQube + Docker
- 1h : Jenkins + Plugins
- 1h : SSH + Ansible
- 1h : Tests unitaires
- 2h : Premier déploiement complet

**Partie II:**

- 2h : Pipeline Partie I complet
- 1h30 : Blue/Green deployment
- 30min : Screenshots + rapport
