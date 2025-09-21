# 1) Déployer nginx + page personnalisée

## 1.1 Namespace & ConfigMap (page d’accueil)

```bash
kubectl create ns webdemo

# Créer une page HTML locale
cat > index.html <<'HTML'
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>NGINX @ Minikube</title></head>
  <body style="font-family:sans-serif">
    <h1>Ça marche 🎉</h1>
    <p>Servi par nginx dans Minikube, exposé via socat sur la VM.</p>
  </body>
</html>
HTML

# La transformer en ConfigMap
kubectl -n webdemo create configmap nginx-index --from-file=index.html
```

## 1.2 Deployment nginx (monte la page via ConfigMap)

```yaml
# nginx-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: webdemo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html/index.html
          subPath: index.html
      volumes:
      - name: html
        configMap:
          name: nginx-index
          items:
          - key: index.html
            path: index.html
```

Appliquer :

```bash
kubectl apply -f nginx-deploy.yaml
kubectl -n webdemo rollout status deploy/nginx
```

## 1.3 Service NodePort (interne au nœud Minikube)

```yaml
# nginx-svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  namespace: webdemo
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - name: http
    port: 80
    targetPort: 80
    nodePort: 30080   # tu peux laisser Kubernetes choisir si tu retires cette ligne
```

Appliquer et vérifier :

```bash
kubectl apply -f nginx-svc.yaml
kubectl -n webdemo get svc nginx -o wide
minikube ip
```

Note le `nodePort` (ex: **30080**) et l’IP Minikube (ex: **192.168.49.2**).

Test **depuis la VM** (pas encore Internet) :

```bash
curl -I http://$(minikube ip):30080/
```

Tu dois voir `HTTP/1.1 200 OK`.

---

# 2) Exposer vers Internet avec **socat**

## 2.1 Installer socat

```bash
sudo apt update
sudo apt install -y socat
```

## 2.2 Redirection live pour test (terminal interactif)

```bash
# Sur la VM : ouvre le port 8080 et redirige vers l’IP minikube:nodePort
socat TCP-LISTEN:8080,fork TCP:$(minikube ip):30080
```

* Laisse cette commande **ouverte** (elle logue les connexions).
* Depuis ton PC, ouvre : `http://IP_PUBLIQUE_VM:8080` → tu dois voir ta page HTML 🎉

> Astuce : préfère **8080** pour éviter les privilèges root sur 80.
> Si tu veux le port **80**, fais : `sudo socat TCP-LISTEN:80,fork TCP:$(minikube ip):30080`

---

# 3) rendenr **persistant** avec systemd (production-friendly)

## 3.1 Unité systemd

```bash
sudo tee /etc/systemd/system/socat-minikube-nginx.service >/dev/null <<'UNIT'
[Unit]
Description=Socat TCP proxy to Minikube NodePort (nginx)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
# Adapter le port local (8080) et le NodePort (30080) si besoin
ExecStart=/usr/bin/socat TCP-LISTEN:8080,fork TCP:$(/usr/bin/minikube ip):30080
Restart=always
RestartSec=2
# Optionnel : limiter la conso
# LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable --now socat-minikube-nginx.service
sudo systemctl status socat-minikube-nginx.service --no-pager
```

Re-test depuis ton PC :
`http://IP_PUBLIQUE_VM:8080` → page **OK**.

---

# 4) Vérifications & Dépannage rapide

* **SG AWS** : le port 8080 (ou 80) doit être **ouvert** en Inbound.

* `curl` local (VM) :
  
  * `curl -I http://$(minikube ip):30080/` → doit répondre **200**.
  * `curl -I http://127.0.0.1:8080/` → doit répondre **200**.

* Logs `socat` (en mode test manuel) : tu vois les connexions arriver.

* `systemctl status socat-minikube-nginx` si service KO.

* Changer de port si un autre service occupe **8080**.

* Si `minikube ip` change (rare mais possible), le service systemd relira la commande à chaque redémarrage.

---

# 5) (Bonus) Ajouter un **2ᵉ déploiement** et l’exposer aussi

## 5.1 Déploiement http-echo (répond un texte)

```yaml
# echo-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo
  namespace: webdemo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo
  template:
    metadata:
      labels:
        app: echo
    spec:
      containers:
      - name: echo
        image: hashicorp/http-echo:0.2.3
        args: ["-text=Hello from echo on Minikube"]
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: echo
  namespace: webdemo
spec:
  type: NodePort
  selector:
    app: echo
  ports:
  - name: http
    port: 80
    targetPort: 5678
    nodePort: 30081
```

Appliquer et tester côté VM :

```bash
kubectl apply -f echo-deploy.yaml
curl -s http://$(minikube ip):30081/
```

## 5.2 Un **deuxième** socat (port différent)

```bash
sudo tee /etc/systemd/system/socat-minikube-echo.service >/dev/null <<'UNIT'
[Unit]
Description=Socat TCP proxy to Minikube NodePort (echo)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/socat TCP-LISTEN:8081,fork TCP:$(/usr/bin/minikube ip):30081
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable --now socat-minikube-echo.service
sudo systemctl status socat-minikube-echo.service --no-pager
```

Depuis ton PC :

* `http://IP_PUBLIQUE_VM:8080` → nginx
* `http://IP_PUBLIQUE_VM:8081` → echo

> Option : tu peux poser un **Nginx** sur l’hôte (Ubuntu) en reverse-proxy pour agréger plusieurs routes sur le **port 80** (ex: `/` → nginx, `/echo` → echo), mais le cœur de la démo ici reste **socat**.

---

# 6) Nettoyage

```bash
# Arrêter les services socat
sudo systemctl disable --now socat-minikube-nginx.service
sudo systemctl disable --now socat-minikube-echo.service
sudo rm -f /etc/systemd/system/socat-minikube-*.service
sudo systemctl daemon-reload

# Supprimer les ressources Kubernetes
kubectl -n webdemo delete svc nginx echo
kubectl -n webdemo delete deploy nginx echo
kubectl -n webdemo delete configmap nginx-index
kubectl delete ns webdemo
```

---

# 1) Deployment nginx

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: webdemo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet: { path: /, port: 80 }
          initialDelaySeconds: 3
          periodSeconds: 5
        livenessProbe:
          httpGet: { path: /, port: 80 }
          initialDelaySeconds: 10
          periodSeconds: 10
```

# 2) Service NodePort

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  namespace: webdemo
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - name: http
    port: 80
    targetPort: 80
    nodePort: 30080   # ou laisse Kubernetes choisir en supprimant cette ligne
```

Application et vérifications :

```bash
kubectl create ns webdemo
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl -n webdemo rollout status deploy/nginx
kubectl -n webdemo get svc nginx -o wide
minikube ip
curl -I http://$(minikube ip):30080/
```

# 3) Exposer vers Internet avec socat (sur la VM Ubuntu/EC2)

Installation :

```bash
sudo apt update && sudo apt install -y socat
```

Test direct (session au premier plan) :

```bash
socat TCP-LISTEN:8080,fork TCP:$(minikube ip):30080
# Ouvre depuis ton PC : http://IP_PUBLIQUE_VM:8080
```

Service systemd (persistant) :

```bash
sudo tee /etc/systemd/system/socat-minikube-nginx.service >/dev/null <<'UNIT'
[Unit]
Description=Socat TCP proxy to Minikube NodePort (nginx)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/socat TCP-LISTEN:8080,fork TCP:$(/usr/bin/minikube ip):30080
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable --now socat-minikube-nginx.service
```

# 4) Ce que ça t’apporte

* **Scalabilité & rolling updates** : augmente/réduis `replicas` (`kubectl -n webdemo scale deploy/nginx --replicas=4`) sans rien changer côté socat.
* **Résilience** : le Service load-balance vers tous les Pods du Deployment.
* **Simplicité** : socat ne vise **jamais** un Pod direct, mais l’IP Minikube + **NodePort** du Service → stable lors des déploiements.

# 5) Dépannage rapide

* Ouvre le port **8080/tcp** dans le Security Group AWS.
* `curl -I http://$(minikube ip):30080/` doit répondre **200** avant de tester via `http://IP_PUBLIQUE_VM:8080`.
* Si `minikube ip` change après un reboot, le service systemd relira la commande (OK).
* Conflit de port ? Change `8080` dans l’unité systemd ou `nodePort` dans le Service.
