# La gestion des processus 

## 1. **`ps` : Lister les processus**

`ps` est la commande de base pour examiner les processus en cours d’exécution sur un système. C’est le point de départ pour identifier les processus actifs et les PID associés afin de diagnostiquer des problèmes ou surveiller l’état général du système.

- **Pourquoi utiliser `ps` ?**
  - **Pour identifier quels processus sont actifs**, à qui ils appartiennent, et quels PID leur sont associés. Cela permet de comprendre l'état actuel du système et d'identifier les processus problématiques.

- **Combinaisons de `ps` les plus courantes :**
  1. **`ps aux`** : Affiche tous les processus en cours avec des informations sur l'utilisateur, la mémoire, le CPU, etc.
     - **Utilité** : Vue complète des processus actifs sur le système, utile pour détecter des processus suspects.
  2. **`ps -ef`** : Affiche tous les processus avec un format plus détaillé, incluant le PID parent (PPID).
     - **Utilité** : Utile pour visualiser la hiérarchie des processus, notamment les processus enfants d'un processus parent spécifique.
  3. **`ps -eo pid,comm,%cpu,%mem --sort=-%cpu`** : Liste les processus par PID, commande, utilisation CPU et mémoire, triés par CPU.
     - **Utilité** : Pratique pour identifier rapidement les processus qui consomment le plus de ressources CPU.
  4. **`ps -C <nom_processus>`** : Filtre les processus en fonction de leur nom.
     - **Utilité** : Localiser rapidement des processus spécifiques par nom (comme `apache2`).
  5. **`ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem`** : Affiche les processus triés par utilisation mémoire.
     - **Utilité** : Pour identifier les processus gourmands en mémoire et analyser leur impact sur les performances du système.

- **Transition vers `top`** : Après avoir identifié les processus consommant beaucoup de ressources avec `ps`, vous pouvez utiliser `top` pour les surveiller en temps réel.

---

## 2. **`top` : Surveillance des processus en temps réel**

`top` permet de surveiller l'utilisation des ressources en temps réel. C’est un outil interactif qui affiche l’utilisation CPU, mémoire et autres paramètres pour chaque processus, trié par défaut par l’utilisation CPU.

- **Pourquoi utiliser `top` ?**
  - **Pour surveiller les processus en temps réel**, voir leur consommation de ressources, et intervenir rapidement en cas de besoin.

- **Combinaisons de `top` les plus courantes :**
  1. **`top`** : Lancer l’interface interactive de `top`.
     - **Utilité** : Vue dynamique des processus et de l’utilisation des ressources, avec possibilité de filtrer, trier et tuer des processus.
  2. **`top -u <username>`** : Filtre les processus d'un utilisateur spécifique.
     - **Utilité** : Permet de suivre les processus d’un utilisateur particulier dans un environnement multi-utilisateurs.
  3. **Touche `P` dans `top`** : Trie les processus par utilisation CPU.
     - **Utilité** : Utile pour surveiller les processus les plus gourmands en CPU en temps réel.
  4. **Touche `M` dans `top`** : Trie les processus par utilisation mémoire.
     - **Utilité** : Pour voir immédiatement quels processus consomment le plus de mémoire.
  5. **Touche `k` dans `top`** : Permet de tuer un processus directement depuis `top`.
     - **Utilité** : Pratique pour une action rapide si un processus consomme trop de ressources.

- **Transition vers `kill`** : Si vous identifiez un processus problématique dans `top`, vous pouvez utiliser `kill` pour le terminer immédiatement.

---

## 3. **`kill` : Terminer les processus**

`kill` est une commande de base utilisée pour envoyer des signaux à un processus. Elle est généralement utilisée pour arrêter un processus en lui envoyant un signal spécifique, tel que SIGTERM ou SIGKILL.

- **Pourquoi utiliser `kill` ?**
  - **Pour arrêter proprement ou forcer l'arrêt d’un processus qui pose problème**, en particulier lorsque celui-ci consomme des ressources excessives ou ne répond plus.

- **Combinaisons de `kill` les plus courantes :**
  1. **`kill <PID>`** : Envoie le signal SIGTERM (par défaut) pour arrêter un processus de manière ordonnée.
     - **Utilité** : Demande à un processus de se terminer proprement.
  2. **`kill -9 <PID>`** : Envoie le signal SIGKILL (9), forçant l’arrêt immédiat du processus.
     - **Utilité** : Utilisé lorsque le processus ne répond pas à un signal SIGTERM.
  3. **`kill -l`** : Liste les signaux disponibles pour `kill`.
     - **Utilité** : Connaître les autres signaux (comme `SIGHUP` pour recharger un processus ou `SIGSTOP` pour le suspendre).
  4. **`kill -SIGSTOP <PID>`** : Suspend un processus sans le terminer.
     - **Utilité** : Suspendre temporairement un processus pour économiser des ressources ou diagnostiquer son état.
  5. **`kill -SIGCONT <PID>`** : Reprend un processus suspendu par `SIGSTOP`.
     - **Utilité** : Reprendre un processus suspendu, par exemple après un ajustement de charge sur le système.
  6. **`killall <nom_processus>`** : Termine tous les processus portant un nom spécifique.
     - **Utilité** : Arrêter rapidement plusieurs instances d’un même processus (comme `killall firefox` pour fermer toutes les fenêtres Firefox).

- **Transition vers `nice` et `renice`** : Avant de tuer un processus, vous pouvez essayer de modifier sa priorité pour qu'il consomme moins de ressources avec `nice` ou `renice`.

---

## 4. **`nice` et `renice` : Gestion des priorités des processus**

`nice` est utilisé pour lancer un processus avec une priorité de CPU spécifique, tandis que `renice` ajuste la priorité d’un processus déjà en cours. Cela permet de mieux gérer l’utilisation du CPU et d’allouer les ressources de manière plus rationnelle.

- **Pourquoi utiliser `nice` et `renice` ?**
  - **Pour ajuster la priorité des processus afin qu'ils consomment les ressources de manière plus appropriée**. Cela est utile pour garantir qu’un processus non critique n’affecte pas la réactivité des processus interactifs.

- **Combinaisons de `nice` et `renice` les plus courantes :**
  1. **`nice -n 10 <command>`** : Lance un processus avec une priorité réduite (10).
     - **Utilité** : Lancer une tâche non critique (comme une sauvegarde ou un encodage) avec une faible priorité pour éviter qu’elle ne monopolise le CPU.
  2. **`renice 10 -p <PID>`** : Modifie la priorité d’un processus en cours pour abaisser sa priorité (10).
     - **Utilité** : Réduire la priorité d’un processus gourmand en CPU afin de libérer des ressources pour d’autres tâches plus importantes.
  3. **`renice -n -5 -p <PID>`** : Augmente la priorité d’un processus déjà en cours (priorité -5).
     - **Utilité** : Donner plus de CPU à un processus critique, par exemple un service réseau qui a besoin de répondre rapidement.
  4. **`nice -n -5 <command>`** : Lance un processus avec une priorité plus élevée que la normale (-5).
     - **Utilité** : Pour des tâches importantes qui doivent être traitées rapidement, comme des processus temps réel ou interactifs.
  5. **`renice -u <username> -n 5`** : Modifie la priorité de tous les processus d’un utilisateur spécifique.
     - **Utilité** : Utile pour ajuster les processus d’un utilisateur si ses tâches ralentissent le système.
  6. **`ps -eo pid,comm,nice --sort=-nice`** : Affiche les processus triés par leur priorité nice.
     - **Utilité** : Permet de repérer les processus avec des priorités très faibles ou élevées et ajuster si nécessaire.

- **Transition vers les commandes auxiliaires** : Une fois que vous avez modifié la priorité ou tué un processus, il peut être utile d’inspecter les fichiers ouverts par le processus ou de surveiller ses comportements plus en détail avec des commandes comme `lsof` ou `strace`.

---

## 5. **Commandes auxiliaires pour la gestion des processus**

### **a) `lsof` : Liste des fichiers ouverts par les processus**

`lsof` permet de voir tous les fichiers ouverts par les processus.

 Cela inclut les fichiers sur disque, les sockets réseau et autres ressources partagées.

- **Pourquoi utiliser `lsof` ?**
  - **Pour comprendre quels fichiers ou connexions un processus utilise**, en particulier dans des scénarios où des fichiers sont verrouillés ou des ports réseau sont utilisés de manière inattendue.

- **Combinaisons de `lsof` les plus courantes :**
  1. **`lsof -p <PID>`** : Affiche tous les fichiers ouverts par un processus via son PID.
     - **Utilité** : Diagnostiquer les fichiers utilisés par un processus avant de le tuer.
  2. **`lsof -u <user>`** : Affiche tous les fichiers ouverts par un utilisateur spécifique.
     - **Utilité** : Surveiller l'activité des utilisateurs et identifier des processus potentiellement indésirables.
  3. **`lsof -i :80`** : Liste les processus qui utilisent un port réseau spécifique (ex. le port 80).
     - **Utilité** : Utile pour vérifier les processus utilisant des ports critiques, par exemple sur des serveurs web.
  4. **`lsof +D /var/www`** : Liste tous les fichiers ouverts dans un répertoire spécifique.
     - **Utilité** : Pour voir quels fichiers dans un répertoire critique, comme `/var/www`, sont utilisés par les processus en cours.
  5. **`lsof -c <nom_processus>`** : Liste les fichiers ouverts par un processus nommé.
     - **Utilité** : Rapide pour inspecter les connexions ou fichiers ouverts par un service.

### **b) `pgrep` : Rechercher des processus par nom**

`pgrep` est utilisé pour rechercher des processus selon leur nom, leur utilisateur ou d’autres critères. Il simplifie la recherche des PIDs pour un processus donné.

- **Pourquoi utiliser `pgrep` ?**
  - **Pour rechercher rapidement les processus sans avoir à passer par `ps` et `grep`**, ce qui est particulièrement utile dans des scripts d’automatisation.

- **Combinaisons de `pgrep` les plus courantes :**
  1. **`pgrep <nom_processus>`** : Affiche les PID des processus ayant un nom spécifique.
     - **Utilité** : Rechercher un processus rapidement pour effectuer d’autres actions (comme le tuer ou modifier sa priorité).
  2. **`pgrep -u <user>`** : Recherche les processus d’un utilisateur spécifique.
     - **Utilité** : Filtrer les processus d’un utilisateur particulier dans un environnement multi-utilisateurs.
  3. **`pgrep -l <nom_processus>`** : Affiche les PID et noms des processus correspondant à la recherche.
     - **Utilité** : Afficher le nom des processus en plus des PID pour plus de clarté.
  4. **`pgrep -f <mot_clef>`** : Recherche dans les commandes complètes au lieu de juste les noms de processus.
     - **Utilité** : Pour les processus qui peuvent avoir des noms de commande courtes mais des arguments de ligne de commande distincts.
  5. **`pgrep -c <nom_processus>`** : Compte le nombre de processus correspondant à la recherche.
     - **Utilité** : Utile pour savoir combien d’instances d’un processus sont actives.

### **c) `strace` : Tracer les appels système d'un processus**

`strace` permet de suivre en détail les appels système effectués par un processus. C’est un outil puissant pour diagnostiquer les comportements anormaux d’un programme.

- **Pourquoi utiliser `strace` ?**
  - **Pour diagnostiquer des processus défaillants ou bloqués** en observant les appels système qu’ils effectuent, ce qui peut indiquer des problèmes d’E/S ou de communication réseau.

- **Combinaisons de `strace` les plus courantes :**
  1. **`strace -p <PID>`** : Trace les appels système d’un processus en cours.
     - **Utilité** : Pour comprendre ce que fait exactement un processus en temps réel, comme lire ou écrire des fichiers.
  2. **`strace -o sortie.log -p <PID>`** : Enregistre le tracé dans un fichier `sortie.log`.
     - **Utilité** : Pour garder une trace persistante de l’activité d’un processus pour une analyse ultérieure.
  3. **`strace <command>`** : Trace tous les appels système générés par une commande donnée.
     - **Utilité** : Pour surveiller les appels système faits par une application au lancement, comme ouvrir des fichiers ou interagir avec le réseau.
  4. **`strace -c -p <PID>`** : Affiche un résumé statistique des appels système d’un processus.
     - **Utilité** : Pour obtenir une vue d’ensemble des appels système effectués par un processus, classés par fréquence.
  5. **`strace -e trace=open,read,write -p <PID>`** : Limite le traçage aux appels spécifiques comme `open`, `read`, et `write`.
     - **Utilité** : Diagnostiquer spécifiquement les appels relatifs aux E/S d'un processus.

### **d) `nohup` : Exécuter un processus sans dépendre du terminal**

`nohup` permet de lancer un processus qui continuera de s’exécuter même après la fermeture du terminal. Cela est particulièrement utile pour les tâches longues sur des serveurs distants.

- **Pourquoi utiliser `nohup` ?**
  - **Pour exécuter une commande longue ou persistante qui continue de tourner après la fermeture du terminal**, par exemple dans une session SSH où vous ne voulez pas perdre votre processus.

- **Combinaisons de `nohup` les plus courantes :**
  1. **`nohup <command> &`** : Lance une commande en arrière-plan, continue après fermeture du terminal.
     - **Utilité** : Pour lancer un processus qui doit durer longtemps, même si la connexion est perdue.
  2. **`nohup <command> > output.log 2>&1 &`** : Redirige la sortie et les erreurs vers un fichier log pour une meilleure analyse.
     - **Utilité** : Conserver les résultats d’un processus en arrière-plan pour consulter les logs plus tard.
  3. **`nohup <command> > /dev/null 2>&1 &`** : Lance une commande en arrière-plan sans afficher de sortie.
     - **Utilité** : Pratique pour les tâches de fond qui n’ont pas besoin de générer de logs.
  4. **`nohup <command> & disown`** : Détache complètement un processus du shell, le laissant indépendant.
     - **Utilité** : Pour libérer le terminal après avoir lancé une tâche longue.
  5. **`jobs -l` et `bg/fg`** : Après avoir utilisé `nohup`, vous pouvez lister les tâches en arrière-plan avec `jobs`, puis utiliser `bg` pour relancer un processus en arrière-plan ou `fg` pour le ramener au premier plan.
     - **Utilité** : Gérer efficacement les processus sans perdre l’accès à ceux lancés en arrière-plan.



### Conclusion

En résumé, les commandes de base comme `ps`, `top`, `kill`, `nice`/`renice` vous permettent de gérer les processus de manière efficace, tandis que les commandes auxiliaires comme `lsof`, `pgrep`, `strace`, et `nohup` offrent des outils spécialisés pour inspecter, surveiller, ou contrôler les processus de manière plus approfondie. Utilisées ensemble, ces commandes permettent de diagnostiquer et résoudre des problèmes complexes, d'optimiser les performances et de maintenir la stabilité de votre système Linux.
