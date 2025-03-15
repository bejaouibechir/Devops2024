**Le fichier d'inventaire:** 

``` ini
[clients]
192.168.100.145  ansible_user=jenkins ansible_ssh_private_key_file=/home/jenkins/.ssh/id_rsa
[clients:vars]
valeur=123
```
**Le playbook de test:**
---
- name: Ajouter ou modifier server_name dans nginx.conf
  hosts: clients
  become: yes
  become_user: jenkins
  tasks:
    - name: Tâche principale
      debug:
        msg: '{{valeur}}'






---
- name: Example de playbook où la varaible est définie au niveau de la tâche
  hosts: ubuntu
  tasks:
  - name: varaible au niveau de la tâche
    set_fact:
      valeur: "Hello, world!"

  - name: Display the task-level variable
    debug:
      msg: "{{ valeur }}"
