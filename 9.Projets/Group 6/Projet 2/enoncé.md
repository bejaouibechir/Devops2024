## ÉNONCÉ DE PROJET – ATELIER DEVOPS

**Bootcamp DevOps – StockMaster (Ansible + Jenkins)**

### 1) Objectif

Mettre en place une solution **Ansible + Jenkins** qui déploie l’application StockMaster (frontend + backend) avec :

- **PostgreSQL 15** en **Master/Slave** (streaming replication)
- **Redis 7** (Docker) + **Sentinel**
- **Tomcat 10.1** externe (déploiement d’un WAR)
- **Nginx** (load balancer + reverse proxy) + frontend statique

### 2) Contexte applicatif (fourni)

- **Backend** : Spring Boot 3.x / Java 17 / Maven, packaging **WAR**
  - Context path : `/stockmaster`
  - API : `/stockmaster/api`
  - Swagger : `/stockmaster/swagger-ui/index.html`
- **Frontend** : Vite + React, build `dist/`
- **Admin** (pré-créé) : `admin` / `Admin123!`

### 3) Architecture cible (5 machines Ubuntu 22.04)

- **M-Central** : Jenkins + Ansible (orchestration SSH)
- **M1** : Nginx + frontend statique
- **M2 + M3** : Tomcat + backend WAR + Redis/Sentinel
- **M4** : PostgreSQL Master
- **M5** : PostgreSQL Slave

### 4) Travail demandé (partie DevOps)

#### A) Playbooks Ansible

Livrer une arborescence `infra/` avec :

- `inventory/hosts.ini` paramétrable
- `group_vars/all.yml` pour centraliser la config
- des **rôles** idempotents (avec `rollback.yml`) :
  - PostgreSQL master / slave (+ réplication)
  - Docker
  - Redis (+ Sentinel)
  - Tomcat (systemd + `setenv.sh`)
  - Déploiement backend WAR (backup + rollback)
  - Déploiement frontend statique
  - Nginx (LB + reverse proxy)
- des **playbooks** (au minimum) :
  - setup database
  - setup infra backend
  - deploy backend
  - setup frontend + nginx
  - smoke tests end-to-end
  - teardown paramétrable (niveau 1/2)

#### B) Pipelines Jenkins

Créer des pipelines simples (déclaratifs) :

- `pipeline-database`
- `pipeline-backend`
- `pipeline-frontend`
- `pipeline-destroy` (avec confirmation)
- `pipeline-master` (orchestration)

Les secrets (clé SSH, mots de passe DB) doivent utiliser **Jenkins Credentials**.

### 5) Contraintes (obligatoires)

1. **Idempotence** : relancer ne doit pas casser
2. **Rollback** : un rollback par rôle
3. **Tags** Ansible : exécution ciblée (database/backend/frontend/master/slave…)
4. **Pas de hardcoding** : IPs et secrets externalisés
5. **Lisibilité** : YAML/Groovy simples (niveau bootcamp)

### 6) Livrables

1. `infra/` complet (rôles + playbooks + templates)
2. Jenkinsfiles/pipelines
3. Un guide de solution (déploiement, tests, rollback)
