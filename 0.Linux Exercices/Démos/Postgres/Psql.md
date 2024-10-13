# Le PSQL

### **Partie 1 : Installation et connexion de base (suite)**

6. **Création d'une table simple** :
   - Créez une table `clients` dans `db_test` avec des colonnes `id`, `nom`, et `age`.
   - Commande : 
     ```sql
     CREATE TABLE clients (
       id SERIAL PRIMARY KEY,
       nom VARCHAR(50),
       age INT
     );
     ```

7. **Insertion de données dans une table** :
   - Ajoutez trois lignes dans la table `clients`.
   - Commande : 
     ```sql
     INSERT INTO clients (nom, age) VALUES 
     ('Alice', 25),
     ('Bob', 30),
     ('Charlie', 35);
     ```

8. **Sélection des données** :
   - Sélectionnez toutes les données de la table `clients`.
   - Commande : `SELECT * FROM clients;`

### **Partie 2 : Gestion des objets de la base**

9. **Mise à jour des données** :
   - Modifiez l’âge de "Bob" à 32.
   - Commande : `UPDATE clients SET age = 32 WHERE nom = 'Bob';`

10. **Suppression d'une ligne** :
    - Supprimez la ligne où `nom` est "Charlie".
    - Commande : `DELETE FROM clients WHERE nom = 'Charlie';`

11. **Ajout d'une colonne** :
    - Ajoutez une colonne `email` à la table `clients`.
    - Commande : `ALTER TABLE clients ADD COLUMN email VARCHAR(100);`

12. **Ajout d'une contrainte unique** :
    - Ajoutez une contrainte unique sur la colonne `email`.
    - Commande : `ALTER TABLE clients ADD CONSTRAINT unique_email UNIQUE (email);`

### **Partie 3 : Gestion des utilisateurs et permissions**

13. **Gestion des permissions** :
    - Donnez à l'utilisateur `user_test` l'accès en lecture seule à la table `clients`.
    - Commande : `GRANT SELECT ON clients TO user_test;`

14. **Vérification des permissions** :
    - Vérifiez les permissions actuelles de la table `clients`.
    - Commande : `\z clients`

15. **Révocation des droits** :
    - Révoquez l'accès de `user_test` à la table `clients`.
    - Commande : `REVOKE ALL ON clients FROM user_test;`

16. **Création d'un rôle** :
    - Créez un rôle `data_analyst` avec des droits de lecture sur toutes les tables.
    - Commande : 
      ```sql
      CREATE ROLE data_analyst;
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO data_analyst;
      ```

17. **Assignation d'un rôle** :
    - Assignez le rôle `data_analyst` à `user_test`.
    - Commande : `GRANT data_analyst TO user_test;`

### **Partie 4 : Gestion avancée des bases et objets**

18. **Création d'un index** :
    - Créez un index sur la colonne `nom` de la table `clients`.
    - Commande : `CREATE INDEX idx_nom ON clients(nom);`

19. **Analyse des performances** :
    - Utilisez `EXPLAIN` pour analyser une requête `SELECT` sur la colonne `nom`.
    - Commande : `EXPLAIN SELECT * FROM clients WHERE nom = 'Alice';`

20. **Suppression d'une colonne** :
    - Supprimez la colonne `email` de la table `clients`.
    - Commande : `ALTER TABLE clients DROP COLUMN email;`

21. **Utilisation des transactions** :
    - Insérez plusieurs lignes dans la table `clients` en utilisant une transaction.
    - Commandes :
      ```sql
      BEGIN;
      INSERT INTO clients (nom, age) VALUES ('David', 28);
      INSERT INTO clients (nom, age) VALUES ('Eva', 23);
      COMMIT;
      ```

### **Partie 5 : Sauvegarde et restauration**

22. **Sauvegarde d'une base de données** :
    - Effectuez une sauvegarde de la base de données `db_test`.
    - Commande : `pg_dump -h 192.168.1.19 -U postgres -d db_test -f db_test_backup.sql`

23. **Restauration d'une base de données** :
    - Restaurez la base de données à partir du fichier de sauvegarde.
    - Commande : `psql -h 192.168.1.19 -U postgres -d db_test -f db_test_backup.sql`

### **Partie 6 : Gestion des vues, triggers et fonctions**

24. **Création d'une vue** :
    - Créez une vue `view_clients` pour afficher les noms et âges des clients.
    - Commande : `CREATE VIEW view_clients AS SELECT nom, age FROM clients;`

25. **Sélection depuis une vue** :
    - Sélectionnez les données à partir de la vue `view_clients`.
    - Commande : `SELECT * FROM view_clients;`

26. **Création d'une fonction** :
    - Créez une fonction qui retourne l’âge moyen des clients.
    - Commande : 
      ```sql
      CREATE FUNCTION avg_age() RETURNS FLOAT AS $$
      BEGIN
        RETURN (SELECT AVG(age) FROM clients);
      END;
      $$ LANGUAGE plpgsql;
      ```

27. **Appel d'une fonction** :
    - Appelez la fonction `avg_age`.
    - Commande : `SELECT avg_age();`

28. **Création d'un trigger** :
    - Créez un trigger pour inscrire la date de modification des données de la table `clients`.
    - Commande : 
      ```sql
      CREATE TRIGGER update_time
      BEFORE UPDATE ON clients
      FOR EACH ROW
      EXECUTE FUNCTION trigger_set_timestamp();
      ```

### **Partie 7 : Sécurité et administration avancée**

29. **Vérification de la connexion** :
    - Listez les connexions actuelles à la base de données.
    - Commande : `SELECT * FROM pg_stat_activity;`

30. **Interruption d'une session** :
    - Tuez une session active en utilisant son PID.
    - Commande : `SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid = <PID>;`

31. **Changement de mot de passe** :
    - Changez le mot de passe de `user_test`.
    - Commande : `ALTER USER user_test WITH PASSWORD 'new_password';`

32. **Création d'un schéma** :
    - Créez un nouveau schéma `finance`.
    - Commande : `CREATE SCHEMA finance;`

33. **Migration de tables vers un schéma** :
    - Déplacez la table `clients` dans le schéma `finance`.
    - Commande : `ALTER TABLE clients SET SCHEMA finance;`

34. **Suppression d'une base de données** :
    - Supprimez la base de données `db_test`.
    - Commande : `DROP DATABASE db_test;`

### **Partie 8 : Maintenance et nettoyage**

35. **Analyse et vacuum** :
    - Exécutez une commande `VACUUM ANALYZE` pour nettoyer et optimiser la base.
    - Commande : `VACUUM ANALYZE;`


Ces exercices vous guideront à travers les fonctionnalités essentielles de `psql` tout en couvrant une gamme de scénarios de gestion des bases de données PostgreSQL.
