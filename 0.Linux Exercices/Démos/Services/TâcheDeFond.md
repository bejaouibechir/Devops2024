# Arrêter une tâche de fond

Pour arrêter un processus comme **`ping 192.168.1.32 &`** qui a été lancé en arrière-plan, voici les étapes :

### 1. **Trouver l'ID du processus (PID)**

- Utilisez la commande `jobs` pour lister les tâches en arrière-plan :
```bash
jobs
```

- Si vous voyez un numéro de job (par exemple, `[1]` pour la tâche en cours), vous pouvez l'arrêter avec :
```bash
kill %1
```
- Sinon, vous pouvez utiliser la commande **`ps`** pour trouver l'ID du processus :

```bash
ps aux | grep ping
```

- Cela affichera la liste des processus avec `ping`. Relevez l'ID de celui que vous souhaitez arrêter (ex: `1234`).

### 2. **Arrêter le processus avec `kill`**

- Une fois l'ID de processus obtenu, utilisez la commande `kill` pour arrêter le processus :
```bash
kill 1234
```

- Si le processus ne se termine pas, utilisez `kill -9` pour forcer son arrêt :
```bash
kill -9 1234
``` 

Cela arrêtera le processus **`ping`** en cours d'exécution.
