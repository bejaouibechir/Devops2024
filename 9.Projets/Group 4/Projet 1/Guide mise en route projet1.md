# Projet 1 – Énoncé officiel

---

## Partie I mise en marche manuelle

## Objectif du projet

Déployer, valider et tester **une application Kubernetes complète** incluant :

- **MySQL persistante**

- **Backend Flask scalable**

- **Autoscaling HPA**

- **Monitoring MySQL**

- **Tests fonctionnels et techniques**

---

## Pré-requis obligatoires

Avant de commencer, l’apprenant doit disposer de :

- Un **cluster Kubernetes fonctionnel**

- Un environnement **Minikube OU cluster standard**

- Un environnement de **build d’images Docker**

- Le code source du **Projet 1**

---

## Étape 1 – Préparer le cluster Kubernetes

1. Démarrer le **cluster Kubernetes**.

2. Vérifier la disponibilité du **stockage persistant**.

3. Vérifier la disponibilité des **métriques Kubernetes**.

Résultat attendu :

- Le cluster est **Ready** et stable.

---

## Étape 2 – Déployer la base MySQL

1. Créer un **namespace dédié**.

2. Définir les **secrets MySQL**.

3. Définir les **scripts d’initialisation**.

4. Déployer MySQL sous forme de **StatefulSet**.

5. Exposer MySQL via des **services internes**.

Résultat attendu :

- MySQL est **Running**

- Les données sont **persistées**

- La base est **accessible depuis le cluster**

---

## Étape 3 – Construire et rendre disponible l’image du backend Flask

**(Étape critique)**

### Cas 1 – Environnement Minikube

1. Construire l’image Docker **dans l’environnement Docker de Minikube**.

2. Vérifier que l’image est **directement disponible localement**.

3. S’assurer que Kubernetes peut consommer l’image **sans registry externe**.

### Cas 2 – Cluster Kubernetes standard

1. Construire l’image Docker.

2. **Taguer l’image** pour un registry valide.

3. **Pousser l’image** vers un **Docker registry**.

4. Configurer Kubernetes pour **tirer l’image**.

Résultat attendu :

- L’image du backend est **accessible par Kubernetes**.

---

## Étape 4 – Déployer le backend Flask

1. Définir les **secrets applicatifs**.

2. Déployer le backend via un **Deployment**.

3. Configurer la **connexion MySQL interne**.

4. Exposer l’API via un **Service Kubernetes**.

5. Activer l’**autoscaling HPA**.

Résultat attendu :

- Le backend est **Running**

- Plusieurs réplicas sont actifs

- La communication MySQL est fonctionnelle

---

## Étape 5 – Tests techniques Kubernetes

**(Validation d’infrastructure)**

1. Vérifier l’état des **pods MySQL**.

2. Vérifier l’état des **pods backend**.

3. Vérifier que les **probes** fonctionnent.

4. Vérifier la résolution **DNS interne** entre backend et MySQL.

5. Vérifier l’absence d’erreurs de type **CrashLoopBackOff** ou **ImagePullBackOff**.

Résultat attendu :

- Tous les pods sont **Ready**

- Aucun événement critique Kubernetes

---

## Étape 6 – Tests fonctionnels de l’API

**(Validation applicative)**

1. Accéder à l’API exposée par Kubernetes.

2. Tester l’endpoint de **santé applicative**.

3. Tester un **appel simple de lecture**.

4. Tester un **appel de création**.

5. Tester un **appel de mise à jour**.

6. Tester un **appel de suppression**.

Résultat attendu :

- Toutes les opérations API fonctionnent

- Les données sont bien **persistées en base**

Astuce :

- Les tests doivent prouver que **l’état survit** à un redémarrage de pod.

---

## Étape 7 – Tests de résilience

**(Comportement en cas d’incident)**

1. Forcer l’arrêt d’un **pod backend**.

2. Observer le **redémarrage automatique**.

3. Vérifier que l’API reste accessible.

4. Forcer l’arrêt du **pod MySQL**.

5. Vérifier la reprise avec **données intactes**.

Résultat attendu :

- Kubernetes assure la **continuité de service**

- Aucune perte de données

---

## Étape 8 – Installer la stack de monitoring

1. Installer une stack **Prometheus + Grafana**.

2. Vérifier la collecte des **métriques cluster**.

3. Vérifier l’accès à **Grafana**.

Résultat attendu :

- Prometheus et Grafana sont **opérationnels**

---

## Étape 9 – Tests de monitoring MySQL

1. Déployer l’**exporter MySQL**.

2. Vérifier que Prometheus **scrape les métriques**.

3. Vérifier les **dashboards MySQL**.

4. Vérifier l’activation des **règles d’alerte**.

Résultat attendu :

- Les métriques MySQL sont visibles

- Les alertes sont prêtes à être déclenchées

---

## Étape 10 – Tests de charge et autoscaling

1. Générer une **charge applicative contrôlée**.

2. Observer l’évolution de la **consommation CPU/Mémoire**.

3. Observer le comportement du **HPA**.

4. Vérifier la création de **nouveaux pods backend**.

5. Vérifier la stabilisation après la charge.

Résultat attendu :

- Le backend **scale automatiquement**

- Le service reste fonctionnel sous charge

---

## Étape 11 – Nettoyage de l’environnement

1. Supprimer les ressources applicatives.

2. Supprimer les namespaces créés.

3. Vérifier que le cluster est **propre**.

Résultat attendu :

- Aucun résidu du Projet 1

---

## Partie II Tester les scripts

Très bonne question — et elle est **structurante** pour comprendre le **sens du projet**, pas juste son exécution.

Je réponds **en style Microsoft**, clair, factuel, **sans blabla**, en expliquant **le rôle précis de chaque script .sh** et **pourquoi ils existent** dans Projet 1.

---

# Projet 1 – Rôle des scripts .sh

Les scripts shell **n’implémentent pas la solution**.  
Ils servent à **orchestrer**, **tester** et **démontrer** le projet.

👉 Le projet doit être **exécutable sans eux**.  
👉 Les scripts sont des **accélérateurs d’atelier**, pas une dépendance.

---

## 1. scripts/deploy-all.sh

### Rôle

Automatiser la **mise en route complète du Projet 1** sur un poste local.

### À quoi il sert

- Démarrer l’environnement **Minikube**

- Activer les **addons requis**

- Construire et rendre disponible l’image backend

- Déployer **MySQL**, **backend**, **HPA**

- Installer la stack **Prometheus + Grafana**

- Appliquer le **monitoring MySQL**

### Pourquoi il existe

- Gagner du temps en **atelier**

- Éviter les erreurs de saisie

- Permettre une **démo rapide formateur**

### À retenir

- Ce script **n’est pas requis** pour comprendre Kubernetes

- Il **masque volontairement** des commandes que l’apprenant doit savoir refaire

---

## 2. scripts/load-test.sh ou load-test.js

### Rôle

Générer une **charge contrôlée** sur l’API.

### À quoi il sert

- Simuler des **requêtes clients**

- Créer de la pression CPU et MySQL

- Déclencher le **HPA**

- Observer le **scaling automatique**

### Pourquoi il existe

- Tester le projet **au-delà du “ça marche”**

- Rendre visible l’intérêt de :
  
  - HPA
  
  - Monitoring
  
  - Metrics Server

### À retenir

- Ce script valide le **fil rouge performance**

- Sans lui, le HPA reste **invisible**

---

## 3. scripts/test-api.sh

### Rôle

Tester rapidement les **endpoints fonctionnels** de l’API.

### À quoi il sert

- Vérifier l’endpoint **health**

- Tester les opérations **CRUD**

- Valider la connexion MySQL

### Pourquoi il existe

- Vérifier que le backend est **fonctionnel**

- Détecter rapidement une erreur de configuration

### À retenir

- Ce script est un **smoke test**

- Il ne remplace pas des tests automatisés complets

---

## 4. scripts/monitoring-check.sh

### Rôle

Valider que le **monitoring fonctionne réellement**.

### À quoi il sert

- Vérifier que l’exporter MySQL est **UP**

- Vérifier que Prometheus **scrape les métriques**

- Vérifier la présence des **alert rules**

### Pourquoi il existe

- Éviter le faux sentiment “tout est installé”

- Forcer une **validation factuelle**

### À retenir

- Monitoring sans vérification = **monitoring inutile**

---

## 5. scripts/cleanup.sh

### Rôle

Nettoyer proprement l’environnement.

### À quoi il sert

- Supprimer les namespaces créés

- Libérer les volumes

- Remettre le cluster dans un état propre

### Pourquoi il existe

- Réinitialiser l’atelier

- Éviter les conflits entre sessions

- Permettre des répétitions rapides

### À retenir

- Le nettoyage fait partie du **cycle de vie Kubernetes**

---

## Synthèse – Pourquoi ces scripts existent

| Script           | Rôle principal                |
| ---------------- | ----------------------------- |
| deploy-all.sh    | Démarrage rapide de l’atelier |
| load-test        | Démonstration HPA             |
| test-api         | Validation fonctionnelle      |
| monitoring-check | Validation observabilité      |
| cleanup          | Fin propre de l’atelier       |

Parfait 👍  
Tu mets le doigt sur **le chaînon manquant** :  
les scripts existent, mais **l’apprenant doit comprendre comment les activer, les suivre et les auditer**, pas juste les lancer comme une boîte noire.

Je t’ajoute donc **une section dédiée**, à intégrer **dans l’énoncé du Projet 1**, toujours :

- **Style Microsoft tutorial**

- **Instructions claires**

- **Étapes numérotées**

- **Mots-clés en gras**

- **Aucune commande**

- **Orientation “observer / comprendre / valider”**

---

# Projet 1 – Mise en action et analyse des scripts

---

## Objectif de cette partie

Apprendre à :

- **Lancer manuellement** chaque script

- **Comprendre ce qu’il déclenche**

- **Observer son impact réel** dans Kubernetes

- **Valider que le résultat attendu est atteint**

Les scripts sont utilisés comme **outil d’observation**, pas comme solution magique.

---

## Étape 12 – Préparer l’exécution des scripts

1. Identifier le dossier **scripts** du projet.

2. Examiner la liste des scripts disponibles.

3. Lire chaque script **avant exécution**.

4. Identifier :
   
   - Les **ressources Kubernetes** manipulées
   
   - Les **outils utilisés**
   
   - Les **actions automatisées**

Résultat attendu :

- L’apprenant sait **ce que chaque script va faire** avant de le lancer.

---

## Étape 13 – Mettre en marche le script de déploiement global

### Script concerné

- **deploy-all.sh**

### Instructions

1. Examiner les sections du script.

2. Identifier :
   
   - La phase **préparation du cluster**
   
   - La phase **construction d’image**
   
   - La phase **déploiement Kubernetes**
   
   - La phase **monitoring**

3. Lancer le script **en mode contrôlé**.

4. Observer l’exécution **ligne par ligne**.

Points d’observation obligatoires :

- Création des **namespaces**

- Déploiement des **pods**

- Attente de l’état **Ready**

- Installation des composants de monitoring

Résultat attendu :

- L’ensemble des composants du Projet 1 est déployé automatiquement.

Astuce :

- Toute erreur affichée doit être **analysée**, pas ignorée.

---

## Étape 14 – Examiner l’impact du déploiement

1. Vérifier l’état des **pods MySQL**.

2. Vérifier l’état des **pods backend**.

3. Vérifier la présence des **services**.

4. Vérifier la création du **HPA**.

5. Vérifier la création des **ressources de monitoring**.

Résultat attendu :

- Toutes les ressources attendues sont présentes et opérationnelles.

---

## Étape 15 – Mettre en marche le script de test API

### Script concerné

- **test-api.sh**

### Instructions

1. Examiner les appels effectués par le script.

2. Identifier les **endpoints API** testés.

3. Lancer le script.

4. Observer les réponses retournées par l’API.

Points de contrôle :

- Endpoint de **santé**

- Opérations de **lecture**

- Opérations de **création**

- Opérations de **suppression**

Résultat attendu :

- L’API répond correctement à toutes les opérations.

---

## Étape 16 – Mettre en marche le script de charge

### Script concerné

- **load-test** (shell ou k6)

### Instructions

1. Examiner le scénario de charge.

2. Identifier :
   
   - Le **nombre de requêtes**
   
   - La **durée**
   
   - Les **endpoints sollicités**

3. Lancer le script de charge.

4. Observer le comportement du cluster **pendant l’exécution**.

Points d’observation obligatoires :

- Augmentation de la charge CPU

- Évolution du **HPA**

- Création de **nouveaux pods backend**

Résultat attendu :

- Le backend scale automatiquement sous charge.

---

## Étape 17 – Examiner le monitoring en temps réel

### Script concerné

- **monitoring-check.sh**

### Instructions

1. Examiner ce que le script vérifie.

2. Identifier les métriques MySQL ciblées.

3. Lancer le script.

4. Comparer les résultats avec l’interface Grafana.

Points de contrôle :

- Exporter MySQL **UP**

- Métriques visibles dans Prometheus

- Données cohérentes dans Grafana

Résultat attendu :

- Le monitoring reflète fidèlement l’activité réelle.

---

## Étape 18 – Nettoyer via script

### Script concerné

- **cleanup.sh**

### Instructions

1. Examiner les ressources supprimées par le script.

2. Vérifier qu’aucune ressource critique hors projet n’est impactée.

3. Lancer le script de nettoyage.

4. Vérifier l’état final du cluster.

Résultat attendu :

- Le cluster est **vide de toute ressource Projet 1**.

---

## Message clé pour l’apprenant

- Un script est **un raccourci**, pas une compétence.

- Chaque script correspond à une **séquence Kubernetes** reproductible manuellement.

- L’objectif final est de **savoir expliquer ce que fait le script sans l’exécuter**.

## Objectif

Automatiser Projet 1 avec GitLab CI :

- Construire l’image Docker du backend

- Taguer et publier l’image dans le Registry GitLab

- Déployer les manifests Kubernetes sur une machine EC2 déjà prête

- Exécuter les scripts sh côté EC2 pour orchestrer le déploiement et les tests

- Tout secret, IP, clé, mot de passe doit passer via des variables GitLab CI

---

# Démarche GitLab CI pour Projet 1

## 1) Préparer le dépôt GitLab

1. Créer le projet GitLab et pousser :
   
   - Code backend
   
   - Manifests Kubernetes
   
   - Dossier scripts

2. Activer le Registry GitLab du projet.

3. Décider du mode de déploiement :
   
   - Déploiement direct depuis GitLab CI via SSH vers EC2
   
   - Ou déploiement via un runner installé sur EC2 (encore plus simple)

Résultat attendu :

- Le dépôt contient tout, et le Registry est prêt à recevoir des images.

---

## 2) Standardiser les images Docker

1. Définir la convention de nom d’image :
   
   - Image backend = registry GitLab du projet + nom backend

2. Définir la stratégie de tags :
   
   - Tag immuable = hash du commit
   
   - Tag de confort = latest (optionnel)

Résultat attendu :

- Chaque pipeline produit une image traçable.

---

## 3) Adapter les manifests pour consommer l’image GitLab

1. Le Deployment backend doit pointer vers l’image du Registry GitLab.

2. Le tag doit être piloté par le pipeline :
   
   - Soit via remplacement de valeur au moment du déploiement
   
   - Soit via un fichier de valeurs ou overlay (Kustomize/Helm)

Résultat attendu :

- Le même manifest peut être déployé avec des versions différentes sans modification manuelle.

---

## 4) Préparer l’accès Kubernetes depuis EC2

Tu as une EC2 déjà configurée : il faut clarifier 2 points côté EC2.

1. Où tourne Kubernetes :
   
   - Minikube sur EC2
   
   - Ou cluster externe accessible depuis EC2

2. Où se trouve la configuration kubeconfig :
   
   - Fichier local sur EC2
   
   - Ou contenu injecté via variable CI

Résultat attendu :

- Depuis EC2, kubectl fonctionne et pointe vers le bon cluster.

---

## 5) Organiser les scripts sh pour usage pipeline

Objectif : les scripts sh doivent pouvoir être appelés en pipeline, sans interaction.

1. Chaque script doit accepter des entrées via variables d’environnement :
   
   - Namespace
   
   - Nom d’image backend
   
   - Tag d’image backend
   
   - Mode minikube ou cluster standard

2. Chaque script doit produire des sorties lisibles :
   
   - Afficher les ressources créées
   
   - Afficher les tests exécutés
   
   - Afficher les erreurs clairement

Résultat attendu :

- Les scripts sont utilisables en mode non interactif dans GitLab CI.

---

## 6) Concevoir le pipeline GitLab CI

Pipeline recommandé en 4 stages.

### Stage A – Validation

1. Vérifier la structure du dépôt.

2. Vérifier la qualité :
   
   - lint yaml (manifests)
   
   - lint shell (scripts)
   
   - vérification basique Python (optionnel)

Résultat attendu :

- Le pipeline échoue tôt si un fichier est cassé.

---

### Stage B – Build

1. Construire l’image backend.

2. Taguer l’image avec :
   
   - tag commit
   
   - tag latest (optionnel)

Résultat attendu :

- Une image prête à être push.

---

### Stage C – Push Registry GitLab

1. Authentifier Docker sur le Registry GitLab.

2. Pousser les tags.

Résultat attendu :

- L’image est disponible dans GitLab Container Registry.

---

### Stage D – Deploy sur EC2

Deux options propres.

Option 1 : GitLab CI se connecte en SSH sur EC2

1. Ouvrir une session SSH non interactive.

2. Sur EC2 :
   
   - récupérer le projet (clone ou pull)
   
   - exécuter le script de déploiement
   
   - appliquer les manifests
   
   - lancer les tests

Option 2 : Runner GitLab installé sur EC2

1. Le job tourne directement sur EC2.

2. Pas besoin de SSH.

3. Le job exécute scripts et kubectl localement.

Résultat attendu :

- Le déploiement est automatique, et les tests confirment le fil rouge.
