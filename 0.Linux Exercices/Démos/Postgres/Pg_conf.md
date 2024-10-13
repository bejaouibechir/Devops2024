# Les configuration sous PostGres

Voici les exercices précédents avec leurs solutions détaillées. Les solutions incluent les étapes à suivre pour réaliser chaque tâche en utilisant **pgAdmin4** et le terminal si nécessaire.

### Exercices sur `postgresql.conf`

#### 1. **Connexion au serveur PostgreSQL**
   - **Solution** :
     1. Ouvrez **pgAdmin4** sur votre PC Windows.
     2. Cliquez sur "Add New Server".
     3. Entrez un nom pour le serveur (ex : **Postgres Linux**).
     4. Dans l'onglet **Connection**, entrez les informations suivantes :
        - **Host name/address** : 192.168.1.29 (adresse de la machine Linux)
        - **Port** : 5432 (ou celui configuré)
        - **Username** et **Password** : ceux du superutilisateur PostgreSQL.
     5. Cliquez sur **Save**.

#### 2. **Modifier le port d'écoute**
   - **Solution** :
     1. Sur la machine Linux, ouvrez le fichier `postgresql.conf` avec un éditeur de texte :
        ```bash
        sudo nano /etc/postgresql/14/main/postgresql.conf
        ```
     2. Recherchez la ligne `port = 5432` et changez-la à `port = 5433`.
     3. Enregistrez et quittez l'éditeur.
     4. Redémarrez le service PostgreSQL :
        ```bash
        sudo systemctl restart postgresql
        ```
     5. Modifiez le port dans pgAdmin4 pour se reconnecter sur 5433.

#### 3. **Activer les logs**
   - **Solution** :
     1. Ouvrez `postgresql.conf` sur la machine Linux.
     2. Recherchez et modifiez les lignes suivantes :
        ```bash
        logging_collector = on
        log_directory = 'pg_log'
        log_filename = 'postgresql-%Y-%m-%d.log'
        ```
     3. Redémarrez PostgreSQL :
        ```bash
        sudo systemctl restart postgresql
        ```
     4. Vérifiez que les fichiers logs sont créés dans le répertoire `/var/log/postgresql/`.

#### 4. **Modifier les paramètres de mémoire (shared_buffers)**
   - **Solution** :
     1. Dans `postgresql.conf`, modifiez la ligne :
        ```bash
        shared_buffers = 128MB
        ```
     2. Redémarrez PostgreSQL pour appliquer la configuration.

#### 5. **Activer le mode auto-vacuum**
   - **Solution** :
     1. Vérifiez que `autovacuum = on` est activé dans `postgresql.conf`.
     2. Pour ajuster la fréquence :
        ```bash
        autovacuum_naptime = 30s
        ```
     3. Redémarrez le service PostgreSQL.

#### 6. **Changer la limite de connexions**
   - **Solution** :
     1. Modifiez `max_connections` dans `postgresql.conf` :
        ```bash
        max_connections = 200
        ```
     2. Redémarrez PostgreSQL.

#### 7. **Configurer la journalisation des erreurs**
   - **Solution** :
     1. Modifiez le niveau d'erreurs à loguer dans `postgresql.conf` :
        ```bash
        log_min_error_statement = error
        ```
     2. Redémarrez PostgreSQL et provoquez une erreur pour tester la configuration.

#### 8. **Configurer la réplication (paramètres de base)**
   - **Solution** :
     1. Modifiez `postgresql.conf` pour activer la réplication :
        ```bash
        wal_level = replica
        max_wal_senders = 5
        ```
     2. Redémarrez PostgreSQL.

### Exercices sur `pg_hba.conf`

#### 9. **Autoriser uniquement les connexions locales**
   - **Solution** :
     1. Ouvrez `pg_hba.conf` :
        ```bash
        sudo nano /etc/postgresql/14/main/pg_hba.conf
        ```
     2. Ajoutez ou modifiez cette ligne pour n'autoriser que les connexions locales :
        ```bash
        host    all    all    127.0.0.1/32    md5
        ```
     3. Redémarrez PostgreSQL.

#### 10. **Autoriser une IP spécifique**
   - **Solution** :
     1. Modifiez `pg_hba.conf` pour ajouter la ligne suivante :
        ```bash
        host    all    all    192.168.1.17/32    md5
        ```
     2. Redémarrez PostgreSQL.

#### 11. **Configurer l’authentification par mot de passe**
   - **Solution** :
     1. Modifiez `pg_hba.conf` pour forcer l'utilisation de l'authentification `md5` :
        ```bash
        host    all    all    0.0.0.0/0    md5
        ```
     2. Redémarrez PostgreSQL et testez avec pgAdmin4.

#### 12. **Restreindre l'accès par rôle**
   - **Solution** :
     1. Modifiez `pg_hba.conf` pour autoriser uniquement un rôle spécifique (ex : `user1`) :
        ```bash
        host    all    user1    192.168.1.17/32    md5
        ```
     2. Redémarrez PostgreSQL.

#### 13. **Accès pour un sous-réseau**
   - **Solution** :
     1. Modifiez `pg_hba.conf` pour autoriser un sous-réseau entier :
        ```bash
        host    all    all    192.168.1.0/24    md5
        ```
     2. Redémarrez PostgreSQL.

#### 14. **Authentification peer**
   - **Solution** :
     1. Modifiez `pg_hba.conf` pour activer l'authentification `peer` pour les connexions locales :
        ```bash
        local   all    all    peer
        ```
     2. Redémarrez PostgreSQL.

### Exercices sur `pg_ident.conf`

#### 15. **Configurer un mapping utilisateur**
   - **Solution** :
     1. Ouvrez `pg_ident.conf` :
        ```bash
        sudo nano /etc/postgresql/14/main/pg_ident.conf
        ```
     2. Ajoutez une ligne pour mapper `linux_user` à `pg_user` :
        ```bash
        map1    linux_user    pg_user
        ```
     3. Modifiez `pg_hba.conf` pour utiliser cette map :
        ```bash
        host    all    all    192.168.1.17/32    ident map=map1
        ```
     4. Redémarrez PostgreSQL.

#### 16. **Ajouter plusieurs mappings d'utilisateurs**
   - **Solution** :
     1. Ajoutez plusieurs mappings dans `pg_ident.conf` :
        ```bash
        map1    linux_user1    pg_user1
        map1    linux_user2    pg_user2
        ```
     2. Redémarrez PostgreSQL et testez les connexions.

### Exercices avancés

#### 17. **Optimisation des performances - work_mem**
   - **Solution** :
     1. Modifiez `postgresql.conf` pour augmenter `work_mem` :
        ```bash
        work_mem = 64MB
        ```
     2. Redémarrez PostgreSQL et exécutez des requêtes complexes.

#### 18. **Activer SSL pour les connexions sécurisées**
   - **Solution** :
     1. Activez SSL dans `postgresql.conf` :
        ```bash
        ssl = on
        ```
     2. Configurez les certificats SSL, puis modifiez `pg_hba.conf` :
        ```bash
        hostssl    all    all    192.168.1.17/32    md5
        ```
     3. Redémarrez PostgreSQL et connectez-vous en utilisant SSL.

#### 19. **Activer la réplication asynchrone**
   - **Solution** :
     1. Activez les paramètres de réplication dans `postgresql.conf` :
        ```bash
        wal_level = replica
        max_wal_senders = 5
        ```
     2. Configurez `pg_hba.conf` pour autoriser la réplication :
        ```bash
        host    replication    replicator    192.168.1.29/32    md5
        ```
     3. Redémarrez PostgreSQL.

#### 20. **Mettre en place un hot standby**
   - **Solution** :
     1. Configurez le serveur principal avec `hot_standby = on` dans `postgresql.conf`.
     2. Modifiez `pg_hba.conf` pour autoriser le serveur secondaire à se connecter.
     3. Configurez le serveur secondaire pour se synchroniser avec le principal.

Ces solutions couvrent un large éventail de configurations possibles pour un serveur PostgreSQL. Vous pourrez les adapter selon vos besoins.
