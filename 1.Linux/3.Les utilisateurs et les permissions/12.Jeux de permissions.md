# Exercices sur les Jeux de permissions

### 1. **Ajouter un utilisateur à un groupe**
   - Créer un utilisateur `user1`.
   - Ajouter `user1` au groupe `developers`.
   - Commande : `usermod -aG developers user1`

### 2. **Modifier les permissions d'un fichier pour un groupe**
   - Créer un fichier `project.txt`.
   - Assigner le groupe `developers` au fichier et donner les droits de lecture.
   - Commandes : 
     - `chown :developers project.txt`
     - `chmod g+r project.txt`

### 3. **Créer un groupe avec des droits restreints**
   - Créer un groupe `interns`.
   - Donner à ce groupe seulement les droits d'exécution sur un script `run.sh`.
   - Commandes : 
     - `groupadd interns`
     - `chmod 750 run.sh`

### 4. **Ajouter plusieurs utilisateurs à un groupe avec des droits spécifiques**
   - Créer deux utilisateurs : `user2`, `user3`.
   - Ajouter les deux au groupe `designers`.
   - Donner au groupe `designers` le droit de modification sur `design.pdf`.
   - Commandes : 
     - `usermod -aG designers user2`
     - `usermod -aG designers user3`
     - `chmod g+w design.pdf`

### 5. **Créer un groupe avec des droits d'accès restreints à plusieurs fichiers**
   - Créer un groupe `qa_team`.
   - Assigner à ce groupe le droit de lecture seulement sur les fichiers `report1.txt` et `report2.txt`.
   - Commandes :
     - `groupadd qa_team`
     - `chown :qa_team report1.txt report2.txt`
     - `chmod 740 report1.txt report2.txt`

### 6. **Révoquer des droits pour un groupe**
   - Le groupe `qa_team` ne doit plus avoir de droits sur `report2.txt`.
   - Commandes :
     - `chmod g-r report2.txt`

### 7. **Assigner un utilisateur à plusieurs groupes**
   - Ajouter `user4` aux groupes `developers` et `interns`.
   - Commande : `usermod -aG developers,interns user4`

### 8. **Contrôler les permissions d'accès sur un répertoire**
   - Créer un répertoire `projects/`.
   - Assigner le groupe `developers` avec des droits de lecture et d'écriture.
   - Commandes : 
     - `chown :developers projects/`
     - `chmod 770 projects/`

### 9. **Créer des groupes avec des permissions différentes sur un même fichier**
   - Le fichier `design.docx` doit être lisible par le groupe `designers` et modifiable par le groupe `developers`.
   - Commandes :
     - `setfacl -m g:developers:rw design.docx`
     - `setfacl -m g:designers:r design.docx`

### 10. **Retirer un utilisateur d'un groupe**
   - Retirer `user2` du groupe `designers`.
   - Commande : `gpasswd -d user2 designers`

### 11. **Créer un groupe avec accès exclusif à un fichier**
   - Créer le groupe `managers`.
   - Donner à ce groupe les droits exclusifs de lecture et modification sur `financials.xls`.
   - Commandes : 
     - `groupadd managers`
     - `chown :managers financials.xls`
     - `chmod 750 financials.xls`

### 12. **Restreindre l'accès à un sous-répertoire pour un groupe**
   - Le sous-répertoire `confidential/` doit être accessible uniquement par le groupe `managers`.
   - Commandes :
     - `chown :managers confidential/`
     - `chmod 750 confidential/`

### 13. **Créer une hiérarchie de groupes avec des permissions cumulatives**
   - Créer deux groupes : `admins` et `supervisors`.
   - Les `admins` doivent avoir des droits complets, et les `supervisors` uniquement des droits de lecture.
   - Commandes :
     - `chown :admins admin_file`
     - `chmod 770 admin_file`
     - `setfacl -m g:supervisors:r admin_file`

### 14. **Configurer des permissions héritées sur un répertoire**
   - Le répertoire `shared/` doit permettre aux membres du groupe `developers` d'hériter des droits d'écriture pour tous les fichiers créés dans ce répertoire.
   - Commande : `chmod g+s shared/`

### 15. **Bloquer un utilisateur spécifique d'un groupe**
   - Empêcher `user5` d'accéder aux fichiers du groupe `developers`.
   - Commande : `setfacl -m u:user5:0 project.txt`

### 16. **Attribuer des permissions temporaires à un groupe**
   - Permettre au groupe `qa_team` de modifier un fichier `testcase.txt` pendant 2 heures.
   - Utilisation d'un **cron** pour révoquer les droits après ce délai.
   - Commandes :
     - `setfacl -m g:qa_team:rw testcase.txt`
     - Ajouter une tâche cron pour révoquer après 2h : `echo "setfacl -x g:qa_team testcase.txt" | at now + 2 hours`

### 17. **Restaurer les permissions par défaut**
   - Réinitialiser les permissions d'un fichier pour qu'elles correspondent uniquement aux groupes standards (`owners`, `others`).
   - Commande : `setfacl -b confidential/`

### 18. **Déléguer les permissions d'administration à un groupe**
   - Le groupe `admins` doit avoir le droit de gérer les permissions d'autres groupes sans être root.
   - Commandes :
     - `setfacl -m g:admins:rwx /etc/sudoers`
     - Ajouter les admins au fichier `/etc/sudoers`.

### 19. **Créer un groupe avec des droits d'exécution et de modification sur des scripts partagés**
   - Le groupe `scripts_team` doit pouvoir exécuter et modifier des scripts dans le dossier `scripts/`, mais pas d'autres groupes.
   - Commandes :
     - `groupadd scripts_team`
     - `chown :scripts_team scripts/`
     - `chmod 770 scripts/`

### 20. **Créer des permissions différentes sur les sous-dossiers pour plusieurs groupes**
   - Le dossier `projects/` contient deux sous-dossiers, `dev/` et `test/`.
   - Le groupe `developers` doit avoir des droits complets sur `dev/` et seulement des droits de lecture sur `test/`.
   - Commandes :
     - `chown :developers projects/dev/`
     - `chown :developers projects/test/`
     - `chmod 770 projects/dev/`
     - `chmod 750 projects/test/`
