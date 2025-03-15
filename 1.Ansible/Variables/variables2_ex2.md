**Le fichier d'inventaire:** 

``` ini
[clients]
192.168.100.145  ansible_user=jenkins ansible_ssh_private_key_file=/home/jenkins/.ssh/id_rsa
[clients:vars]
valeur=123
```
**Le playbook de test:**

``` yml
---
- name: Ajouter ou modifier server_name dans nginx.conf
  hosts: clients
  become: yes
  become_user: jenkins
  tasks:
    - name: Tâche principale
      debug:
        msg: '{{valeur}}'


```






--
