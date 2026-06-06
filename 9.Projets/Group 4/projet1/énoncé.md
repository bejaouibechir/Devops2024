# Énoncé de Projet — Pipeline CI/CD Jenkins + Ansible + Tomcat

## Contexte

Dans le cadre de ce projet, vous allez mettre en place une chaîne **CI/CD complète** pour une application **Spring Boot** (Maven). Le pipeline automatise le clonage du code source, sa compilation, l'installation de Tomcat sur une machine distante via Ansible, et le déploiement de l'artefact WAR généré.

---

## Architecture cible

```
Machine locale
    │  (SSH key / git push)
    ▼
GitLab SCM  (RemoteProject)
    │  (username / token)
    ▼
JenkinsSrv  ──── Ansible ────►  ProdMachine  (Tomcat 10 / Java 17)
                              └──────────────► ProdMachine2 (optionnel)
```

**Infrastructure requise : 3 machines virtuelles (VirtualBox / VMware)**

| VM | Rôle | Services |
|----|------|----------|
| JenkinsSrv | Serveur CI/CD | Jenkins, Ansible |
| ProdMachine | Serveur de production 1 | Tomcat 10, Java 17 |
| ProdMachine2 | Serveur de production 2 (bonus) | Tomcat 10, Java 17 |

---

## Travail demandé

### Partie 1 — Connexion Machine Locale ↔ GitLab

1. Générer une paire de clés SSH (`ssh-keygen`) sur votre machine locale.
2. Ajouter la clé publique dans les paramètres GitLab (*Settings → SSH Keys*).
3. Cloner le dépôt via SSH et vérifier que le `git push` fonctionne sans mot de passe.

### Partie 2 — Connexion Jenkins ↔ GitLab

1. Créer un **Access Token** GitLab avec les scopes `api`, `read_repository`, `write_repository`.
2. Dans Jenkins (*Manage Jenkins → Credentials → Global*), créer un credential de type **Username/Password** :
   - Username : votre nom de compte GitLab
   - Password : le token généré
3. Créer un **Pipeline project** Jenkins nommé `remoteproject`.
4. Configurer le stage `Check SCM` pour récupérer le code depuis GitLab en utilisant le credential créé.
5. Vérifier que le workspace Jenkins (`/var/lib/jenkins/workspace/remoteproject`) contient bien les sources après un premier build.

### Partie 3 — Build Maven

1. Ajouter un stage `build` dans le pipeline :
   ```groovy
   stage('build') {
       steps {
           sh 'mvn clean package'
       }
   }
   ```
2. Vérifier que le fichier `demo-0.0.1-SNAPSHOT.war` est généré dans le dossier `target/`.

### Partie 4 — Installation automatisée de Tomcat via Ansible

Créer un playbook Ansible `i_tomcat.yml` **colocalisé avec le code source dans le dépôt GitLab** qui :

1. Vérifie la présence d'un **marker file** (`/opt/tomcat/.tomcat_installed`) pour éviter une réinstallation inutile.
2. Exécute `apt update && apt upgrade`.
3. Installe **Java 17** (`default-jdk`).
4. Télécharge l'archive Tomcat 10 depuis le site officiel Apache.
5. Extrait l'archive vers `/opt/tomcat`.
6. Transfère la propriété du répertoire à l'utilisateur **jenkins**.
7. Donne les droits d'exécution aux scripts dans `/opt/tomcat/bin`.
8. Écrase les fichiers de configuration par défaut avec les fichiers fournis :
   - `tomcat-users.xml` → `/opt/tomcat/conf/tomcat-users.xml`
   - `manager-context.xml` → `/opt/tomcat/webapps/manager/META-INF/context.xml`
   - `hmanager-context.xml` → `/opt/tomcat/webapps/host-manager/META-INF/context.xml`
9. Lance Tomcat via `startup.sh`.
10. Crée le marker file à la fin.

> **Note :** Les trois fichiers XML de configuration doivent être présents dans le dépôt GitLab au même niveau que le playbook.

Intégrer l'appel au playbook dans le pipeline Jenkins via `withCredentials` pour passer le mot de passe `become` de manière sécurisée :

```groovy
stage('install tomcat') {
    steps {
        withCredentials([string(credentialsId: 'secret-test', variable: 'BECOME_CREDENTIALS')]) {
            sh '''
            ansible-playbook i_tomcat.yml \
              --extra-vars "ansible_become_pass=$BECOME_CREDENTIALS"
            '''
        }
    }
}
```

### Partie 5 — Déploiement de l'application

1. Créer un playbook Ansible `deploy.yml` qui copie le fichier WAR généré vers `/opt/tomcat/webapps/` sur la machine cible.
2. Ajouter le stage `deployer la solution` dans le pipeline.
3. Vérifier depuis la machine ProdMachine que le WAR est bien présent dans `/opt/tomcat/webapps/`.
4. Accéder à l'application via `http://<IP_ProdMachine>:8080/demo-0.0.1-SNAPSHOT`.

---

## Structure du dépôt GitLab attendue

```
RemoteProject/
├── src/                        # Code source Spring Boot
├── pom.xml
├── mvnw / mvnw.cmd
├── i_tomcat.yml                # Playbook installation Tomcat
├── deploy.yml                  # Playbook déploiement WAR
├── tomcat-users.xml            # Config utilisateurs Tomcat
├── manager-context.xml         # Config Manager
└── hmanager-context.xml        # Config Host Manager
```

---

## Pipeline Jenkins final attendu

```
Check SCM  →  build  →  install tomcat  →  deployer la solution
   2s           35s          9s                   21s
```

---

## Livrables

- Dépôt GitLab contenant le code source + les playbooks Ansible + les fichiers de configuration.
- Pipeline Jenkins fonctionnel avec les 4 stages qui passent au vert.
- Capture d'écran du **Stage View** Jenkins montrant le pipeline complet.
- Capture d'écran de Tomcat Manager (`http://<IP>:8080/manager`) confirmant le déploiement.
- Capture d'écran de la machine ProdMachine confirmant la présence du WAR dans `/opt/tomcat/webapps/`.

---

## Critères d'évaluation

| Critère | Points |
|---------|--------|
| Connexion SSH locale ↔ GitLab fonctionnelle | 2 |
| Credential Jenkins ↔ GitLab configuré | 2 |
| Stage `build` : WAR généré correctement | 3 |
| Playbook `i_tomcat.yml` : Tomcat installé et opérationnel | 5 |
| Fichiers de configuration Tomcat corrects (users, manager, hmanager) | 3 |
| Utilisation de `withCredentials` pour le become password | 2 |
| Playbook `deploy.yml` : WAR déployé sur ProdMachine | 5 |
| Pipeline Jenkins 4 stages au vert | 3 |
| Bonus : déploiement sur ProdMachine2 | +3 |
| **Total** | **25** |

---

## Conseils

- Le lien de téléchargement de Tomcat change à chaque version. Toujours récupérer l'URL officielle depuis [https://tomcat.apache.org/download-10.cgi](https://tomcat.apache.org/download-10.cgi).
- Ne jamais stocker de mot de passe en clair dans le Jenkinsfile. Utiliser systématiquement les **Credentials Jenkins**.
- Pour éviter une réinstallation de Tomcat à chaque build, le **marker file** est indispensable.
- Vérifier le chemin exact du WAR dans `target/` avant de le coder dans `deploy.yml` (il dépend de l'`artifactId` et de la `version` dans `pom.xml`).
