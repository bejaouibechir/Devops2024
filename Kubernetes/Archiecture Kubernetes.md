#Architecture Kubernetes

```mermaid
graph TD
    subgraph Master Node
        APIServer[API Server]
        Scheduler[Scheduler]
        ControllerManager[Controller Manager]
        etcd[etcd]
    end

    subgraph Worker Node 1
        kubelet1[kubelet]
        kubeProxy1[kube-proxy]
        Pod1[Pod]
    end

    subgraph Worker Node 2
        kubelet2[kubelet]
        kubeProxy2[kube-proxy]
        Pod2[Pod]
    end

    subgraph Worker Node N
        kubeletN[kubelet]
        kubeProxyN[kube-proxy]
        PodN[Pod]
    end

    APIServer --> Scheduler
    APIServer --> ControllerManager
    APIServer --> etcd
    APIServer --> kubelet1
    APIServer --> kubelet2
    APIServer --> kubeletN
    kubelet1 --> Pod1
    kubelet2 --> Pod2
    kubeletN --> PodN
    kubeProxy1 --> Pod1
    kubeProxy2 --> Pod2
    kubeProxyN --> PodN

```

### Explications rapides :
- **Master Node** :
  - **API Server** : Interface centrale pour gérer Kubernetes.
  - **Scheduler** : Attribue des Pods aux nœuds.
  - **Controller Manager** : Supervise les boucles de contrôle.
  - **etcd** : Base de données distribuée pour stocker l'état du cluster.

- **Worker Nodes** :
  - **kubelet** : Assure que les conteneurs sont en cours d'exécution.
  - **kube-proxy** : Gère le réseau et le routage.
  - **Pods** : Unité de déploiement contenant un ou plusieurs conteneurs.

- La communication se fait via l'**API Server**, et **etcd** conserve l'état global du cluster.
