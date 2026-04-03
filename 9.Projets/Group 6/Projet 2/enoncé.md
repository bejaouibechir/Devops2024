

# 🧪 Projet DevOps – StockMaster (Ansible + Jenkins)

## 1. Objectif général ( *pourquoi ce projet ?*)

Vous allez mettre en place une **chaîne de déploiement automatisée** complète pour une application web réelle (*StockMaster*).  
L’objectif est de simuler un environnement de production avec :

- Plusieurs machines (5)
- Une base de données répliquée (PostgreSQL)
- Un cache distribué (Redis + Sentinel)
- Un équilibreur de charge (Nginx)
- Un serveur d’application (Tomcat)
- De l’orchestration via **Ansible**
- De l’intégration continue via **Jenkins**

> 💡 C’est exactement ce qu’un **DevOps junior** doit savoir construire.

---

## 2. Ce que fait l’application ( *contexte applicatif*)

Vous n’avez pas à coder l’appli – elle est fournie.  
Voici ses composants techniques :

| Composant   | Technologie                          | Détail utile pour vous           |
| ----------- | ------------------------------------ | -------------------------------- |
| Backend     | Spring Boot 3 + Java 17 + Maven      | Produit un fichier **WAR**       |
| Frontend    | Vite + React                         | Build statique (dossier `dist/`) |
| Accès admin | `admin` / `Admin123!`                | À utiliser pour tester           |
| API         | `/stockmaster/api`                   | Point d’entrée REST              |
| Swagger     | `/stockmaster/swagger-ui/index.html` | Pour tester sans frontend        |

> 🔧 Vous allez **déployer** ces artefacts, pas les compiler (sauf si vous voulez enrichir).

---

## 3. Architecture cible ( *5 machines Ubuntu 22.04*)

| Machine       | Rôle principal                    | Ce qu’il contient                                |
| ------------- | --------------------------------- | ------------------------------------------------ |
| **M-Central** | Pilotage (Jenkins + Ansible)      | Ne déploie **aucune** appli, mais orchestre tout |
| **M1**        | Reverse proxy + frontend statique | Nginx + fichiers HTML/JS/CSS                     |
| **M2**        | Backend + cache                   | Tomcat (WAR) + Redis + Sentinel                  |
| **M3**        | Backend + cache (redondance)      | Tomcat (WAR) + Redis + Sentinel                  |
| **M4**        | Base de données (maître)          | PostgreSQL (replication source)                  |
| **M5**        | Base de données (esclave)         | PostgreSQL (replication cible)                   |

> 🧠 Pourquoi 2 serveurs Tomcat ? Pour tester le **load balancing** avec Nginx.

---

## 4. Ce que vous devez produire ( *partie DevOps*)

### A) Les playbooks Ansible

Vous allez organiser votre code dans un dossier `infra/` comme ceci :

```bash
infra/
├── inventory/
│   └── hosts.ini            # IPs des 5 machines
├── group_vars/
│   └── all.yml              # Variables globales (pas d’IP en dur)
├── roles/
│   ├── postgres_master/
│   ├── postgres_slave/
│   ├── docker/
│   ├── redis_sentinel/
│   ├── tomcat/
│   ├── deploy_backend/
│   ├── deploy_frontend/
│   └── nginx_lb/
├── playbooks/
│   ├── setup_database.yml
│   ├── setup_infra_backend.yml
│   ├── deploy_backend.yml
│   ├── setup_frontend_nginx.yml
│   ├── smoke_tests.yml
│   └── teardown.yml
└── rollback/
    └── rollback.yml         # par rôle
```

#### Règles obligatoires (pédagogiques) :

- **Idempotence** : relancer un playbook ne doit **jamais** casser ce qui est déjà en place.
- **Rollback** : chaque rôle doit pouvoir annuler son dernier déploiement.
- **Tags Ansible** : pour exécuter uniquement la partie souhaitée (`--tags database,backend`).
- **Pas de hardcoding** : les IP, mots de passe, chemins → dans `group_vars/all.yml`.

### B) Les pipelines Jenkins

Vous allez créer **5 pipelines** (fichiers `Jenkinsfile`) :

| Pipeline            | Objectif simple                                     |
| ------------------- | --------------------------------------------------- |
| `pipeline-database` | Déploie PostgreSQL master + slave                   |
| `pipeline-backend`  | Déploie Tomcat + Redis + WAR                        |
| `pipeline-frontend` | Déploie Nginx + frontend statique                   |
| `pipeline-destroy`  | Détruit l’environnement (avec confirmation humaine) |
| `pipeline-master`   | Orchestre les 3 premiers pipelines (CI complète)    |

>  Tous les secrets (clé SSH, mots de passe PostgreSQL, etc.) doivent être dans **Jenkins Credentials**, pas dans le code.

---

## 5. Contraintes importantes ( *à ne pas oublier*)

1. ✅ **Relancez plusieurs fois** → toujours le même résultat.
2. ✅ **Rollback possible** → sans recompilation.
3. ✅ **Tags Ansible** → exécution ciblée.
4. ✅ **Aucune IP en dur** → tout dans l’inventaire ou `group_vars`.
5. ✅ **Code lisible** → commentez ce qui n’est pas évident.

---

## 6. Livrables attendus ( *ce que vous rendez*)

1. Dossier `infra/` complet (rôles, playbooks, templates, vars)
2. Fichiers `Jenkinsfile` pour chaque pipeline
3. **Guide de solution** (fichier `SOLUTION.md`) contenant :
   - Comment déployer depuis zéro
   - Comment tester que tout fonctionne (`smoke tests`)
   - Comment faire un rollback pas à pas
   - Exemple de sortie d’un playbook réussi

---

## 7. Conseils pédagogiques ( *par où commencer ?*)

1. **D’abord à la main** : installez PostgreSQL, Redis, Tomcat sur une seule VM.
2. **Puis automatisez** : transformez ces commandes en rôles Ansible.
3. **Ajoutez la réplication** : PostgreSQL Master/Slave est le plus technique.
4. **Testez avec `ansible-playbook --check`** (mode dry-run).
5. **Ensuite Jenkins** : lancez les playbooks depuis un pipeline simple.
6. **Enfin le rollback** : copiez les anciens WAR/fichiers avant de déployer.

---

### À retenir pour votre futur métier

> Un bon projet DevOps ne consiste pas à *faire marcher* une appli, mais à **rendre son déploiement fiable, reproductible et réversible**.

Bon courage 
