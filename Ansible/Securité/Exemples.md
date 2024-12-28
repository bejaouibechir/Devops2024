# Exercices sur Ansible Vault

Voici **deux exercices** pour sécuriser vos playbooks avec **Ansible Vault** :

---

### **Exercice 1 : Crypter des variables sensibles dans un playbook**

**Objectif** : Protéger des informations sensibles comme des mots de passe dans un fichier de variables à l'aide d'Ansible Vault.

#### Étapes :
1. Créez un fichier contenant des variables sensibles :
   ```bash
   echo -e "db_user: admin\ndb_password: secret123" > secrets.yml
   ```

2. Cryptez le fichier avec Ansible Vault :
   ```bash
   ansible-vault encrypt secrets.yml
   ```

3. Intégrez ce fichier dans un playbook pour configurer une base de données :
   **Playbook** : `playbook.yml`
   ```yaml
   - name: Configure database with Ansible Vault
     hosts: localhost
     vars_files:
       - secrets.yml
     tasks:
       - name: Display database credentials
         debug:
           msg: "Database user: {{ db_user }}, Password: {{ db_password }}"
   ```

4. Exécutez le playbook avec le mot de passe Ansible Vault :
   ```bash
   ansible-playbook playbook.yml --ask-vault-pass
   ```

---

### **Exercice 2 : Mettre à jour et décrypter un fichier chiffré avec Ansible Vault**

**Objectif** : Modifier et lire un fichier chiffré.

#### Étapes :
1. Créez un fichier chiffré pour un mot de passe SSH :
   ```bash
   echo "ssh_password: my_ssh_secret" > ssh_secrets.yml
   ansible-vault encrypt ssh_secrets.yml
   ```

2. Ajoutez une tâche pour afficher ce mot de passe dans un playbook :
   **Playbook** : `ssh_playbook.yml`
   ```yaml
   - name: Use encrypted SSH secrets
     hosts: localhost
     vars_files:
       - ssh_secrets.yml
     tasks:
       - name: Display SSH password
         debug:
           msg: "SSH Password: {{ ssh_password }}"
   ```

3. Exécutez le playbook pour vérifier :
   ```bash
   ansible-playbook ssh_playbook.yml --ask-vault-pass
   ```

4. Décryptez le fichier pour modifier le mot de passe :
   ```bash
   ansible-vault decrypt ssh_secrets.yml
   ```

5. Modifiez le fichier (exemple : `ssh_password: new_secret123`), puis le re-chiffrez :
   ```bash
   ansible-vault encrypt ssh_secrets.yml
   ```

---

Ces exercices montrent comment protéger, modifier et utiliser des informations sensibles en toute sécurité avec **Ansible Vault**. Souhaitez-vous ajouter d'autres exemples ou approfondir certaines étapes ?
