### **Démo : Création d'un Pod contenant une application Flask et Redis dans Kubernetes**

#### **1. Objectif**
- Créer un Pod Kubernetes contenant deux conteneurs :
  1. **Application Flask** : Fournit un service Web qui interagit avec Redis.
  2. **Instance Redis** : Stocke des données accessibles par l’application Flask.
- Démontrer l’exécution et l’interaction entre les conteneurs.
- Exposer le Pod pour tester l’application Flask via un navigateur.

---

#### **2. Code source de l'application Flask**

Créez un fichier `app.py` :

```python
from flask import Flask
import redis

app = Flask(__name__)

# Connect to Redis
redis_client = redis.StrictRedis(host='localhost', port=6379, decode_responses=True)

@app.route('/')
def home():
    redis_client.incr('visits')
    visits = redis_client.get('visits')
    return f"Hello from Flask! Total visits: {visits}"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

Créez un fichier `requirements.txt` :

```
flask
redis
```

---

#### **3. Construire les images**

**Dockerfile pour Flask** :
Créez un fichier `Dockerfile` pour Flask :

```dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY app.py requirements.txt /app/
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```

**Construire les images Docker** :
- Construisez l'image Flask :
  ```bash
  docker build -t flask-app:1.0 .
  ```
- Téléchargez l'image Redis :
  ```bash
  docker pull redis:7
  ```

---

#### **4. Créer le Pod à partir de ces images**

Créez un fichier `flask-redis-pod.yaml` :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: flask-redis-pod
  labels:
    app: flask-redis
spec:
  containers:
  - name: flask-container
    image: flask-app:1.0
    ports:
    - containerPort: 5000
    env:
    - name: REDIS_HOST
      value: "localhost"
    - name: REDIS_PORT
      value: "6379"
  - name: redis-container
    image: redis:7
    ports:
    - containerPort: 6379
```

Appliquez le manifest :
```bash
kubectl apply -f flask-redis-pod.yaml
```

---

#### **5. Explorer le Pod**

1. **Vérifiez que le Pod est créé :**
   ```bash
   kubectl get pods
   ```

2. **Examinez les détails du Pod :**
   ```bash
   kubectl describe pod flask-redis-pod
   ```

3. **Affichez les logs de chaque conteneur :**
   - Logs de Flask :
     ```bash
     kubectl logs flask-redis-pod -c flask-container
     ```
   - Logs de Redis :
     ```bash
     kubectl logs flask-redis-pod -c redis-container
     ```

4. **Exécutez des commandes dans les conteneurs :**
   - Exécutez une commande dans le conteneur Flask :
     ```bash
     kubectl exec -it flask-redis-pod -c flask-container -- /bin/bash
     ```
   - Exécutez une commande dans le conteneur Redis :
     ```bash
     kubectl exec -it flask-redis-pod -c redis-container -- redis-cli
     ```

---

#### **6. Exposer le Pod pour consommation via navigateur**

1. Créez un Service pour exposer le Pod :
   ```bash
   kubectl expose pod flask-redis-pod --type=NodePort --port=5000
   ```

2. Vérifiez le port attribué :
   ```bash
   kubectl get service flask-redis-pod
   ```

   Notez le **NodePort** (par exemple : `31500`).

3. Accédez à l’application Flask depuis votre navigateur en utilisant :
   ```
   http://<EC2-Instance-IP>:<NodePort>
   ```

> Note: vous devez ajouter une exception au port 5000 (ou au NodePort attribué, par exemple 31500) dans les règles de sécurité entrantes de votre instance EC2 pour permettre l'accès à l'application via le navigateur.

#### **7. Résultat attendu**
- L’application Flask affiche le nombre de visites, avec les données stockées et récupérées depuis Redis.
- Vous pouvez interagir avec l’application via le navigateur et voir les logs reflétant les opérations Redis.

--- 

## Utilisation de LoadBalancer

> Les nodeport sont limités en termes de Port entre 30000-32767 et ne sont pas pris en considèration par le cloud exemple affectation automatique d'addresse @IP

### **Pourquoi LoadBalancer est préférable sur AWS ?**
1. **Simplicité d'accès** :
   - Le LoadBalancer attribue automatiquement une adresse IP publique ou un DNS géré par AWS.
   - Vous n'avez pas besoin de connaître l'adresse IP de l'EC2 ni d'ajouter des exceptions manuelles aux groupes de sécurité pour des ports spécifiques.

2. **Scalabilité** :
   - Le LoadBalancer peut distribuer le trafic vers plusieurs nœuds Kubernetes (utile si le Pod est répliqué).

3. **Flexibilité** :
   - AWS Elastic Load Balancers (ELB) offrent des fonctionnalités comme SSL/TLS et la gestion avancée du trafic.

4. **Éviter les limites de NodePort** :
   - Les NodePorts utilisent un port fixe compris entre 30000 et 32767, ce qui peut poser des problèmes dans des environnements complexes.

---

### **Mise à jour : Exposition avec LoadBalancer**

#### Modifiez le manifeste pour inclure un Service :

Ajoutez ce fichier `flask-redis-service.yaml` :

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-redis-service
spec:
  type: LoadBalancer
  ports:
  - port: 5000
    targetPort: 5000
    protocol: TCP
  selector:
    app: flask-redis
```

#### Appliquez le manifest :
```bash
kubectl apply -f flask-redis-service.yaml
```

#### Vérifiez le Service :
```bash
kubectl get service flask-redis-service
```

- Une adresse IP publique ou un DNS sera attribué sous la colonne `EXTERNAL-IP`. Utilisez cette adresse pour accéder à l'application Flask.

---

### **Conclusion**
- Utiliser un **Service de type LoadBalancer** est la meilleure pratique sur AWS.
- Vous bénéficiez d’un accès facile, sécurisé et géré par AWS sans avoir besoin d'ajouter des règles manuelles pour des ports spécifiques.


