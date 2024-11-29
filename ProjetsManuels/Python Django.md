## **Tutoriel : Création d'une application Django sur Ubuntu 22.04**



### **1. Préparation de l'environnement**

#### **1.1 Vérifier l'installation de Python et pip**
1. **Vérifiez si Python 3 est installé** :
   ```bash
   python3 --version
   ```
   - Si Python n'est pas installé, demandez à votre administrateur système d'installer :
     ```bash
     sudo apt update
     sudo apt install -y python3
     ```

2. **Vérifiez si pip est installé** :
   ```bash
   pip3 --version
   ```
   - Si pip3 n'est pas installé :
     ```bash
     sudo apt install -y python3-pip
     ```

---

#### **1.2 Installer Django**
1. **Installez Django avec pip** :
   ```bash
   pip3 install django
   ```

2. **Vérifiez si Django est installé correctement** :
   ```bash
   django-admin --version
   ```

---

#### **1.3 Résolution de problèmes si `django-admin` n'est pas trouvé**

Si la commande `django-admin` retourne "command not found", cela signifie que Django a été installé localement (par défaut). Voici comment corriger cela :

1. **Ajoutez `~/.local/bin` au chemin (`PATH`) temporairement** :
   ```bash
   export PATH=$PATH:~/.local/bin
   ```

2. **Ajoutez ce chemin au fichier `~/.bashrc` pour rendre le changement permanent** :
   ```bash
   echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **Testez à nouveau** :
   ```bash
   django-admin --version
   ```

---

### **2. Création de la structure du projet Django**

1. **Créez un nouveau projet Django** :
   ```bash
   django-admin startproject my_django_app
   cd my_django_app
   ```

2. **Créez une application interne nommée `home`** :
   ```bash
   python3 manage.py startapp home
   ```

3. La structure du projet devrait ressembler à ceci :
   ```
   my_django_app/
   ├── manage.py
   ├── my_django_app/
   │   ├── __init__.py
   │   ├── asgi.py
   │   ├── settings.py
   │   ├── urls.py
   │   └── wsgi.py
   ├── home/
   │   ├── __init__.py
   │   ├── admin.py
   │   ├── apps.py
   │   ├── migrations/
   │   │   └── __init__.py
   │   ├── models.py
   │   ├── tests.py
   │   └── views.py
   └── db.sqlite3
   ```

---

### **3. Configuration des fichiers**

#### **3.1 Ajouter l'application `home` à `settings.py`**
- **Chemin** : `my_django_app/my_django_app/settings.py`
- **Code à modifier** :
  Ajoutez l'application `home` dans la liste `INSTALLED_APPS` :
  ```python
  INSTALLED_APPS = [
      'django.contrib.admin',
      'django.contrib.auth',
      'django.contrib.contenttypes',
      'django.contrib.sessions',
      'django.contrib.messages',
      'django.contrib.staticfiles',
      'home',  # Ajoutez ici
  ]
  ```

---

#### **3.2 Configurer les URLs**
- **Chemin** : `my_django_app/my_django_app/urls.py`
- **Code :**

```python
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('home.urls')),  # Inclure les routes de l'application 'home'
]
```

---

#### **3.3 Créer un fichier `urls.py` pour l’application `home`**
1. Créez le fichier dans le dossier `home` :
   ```bash
   nano my_django_app/home/urls.py
   ```
2. Ajoutez le code suivant :
   ```python
   from django.urls import path
   from . import views

   urlpatterns = [
       path('', views.index, name='index'),  # Route vers la vue index
   ]
   ```

---

#### **3.4 Ajouter une vue dans `views.py`**
- **Chemin** : `my_django_app/home/views.py`
- **Code :**

```python
from django.http import HttpResponse

def index(request):
    return HttpResponse("<h1>Welcome to Django App!</h1>")
```

- **Explication** :
  - Cette vue retourne une réponse simple pour la page d'accueil.

---

### **4. Exécution de l'application**

#### **4.1 Migration initiale**
1. Créez les fichiers nécessaires pour la base de données SQLite :
   ```bash
   python3 manage.py makemigrations
   ```
2. Appliquez les migrations :
   ```bash
   python3 manage.py migrate
   ```

#### **4.2 Lancer le serveur**
1. Exécutez le serveur de développement :
   ```bash
   python3 manage.py runserver 0.0.0.0:8000
   ```
2. Accédez à l'application via un navigateur :
   [http://<EC2_PUBLIC_IP>:8000](http://<EC2_PUBLIC_IP>:8000)

---

### **5. Résultat attendu**

1. La page d'accueil affiche :
   ```
   Welcome to Django App!
   ```

---

### **6. Vérifications importantes pour les étudiants**

1. **Avant de commencer, vérifiez :**
   - **Python :**
     ```bash
     python3 --version
     ```
   - **pip :**
     ```bash
     pip3 --version
     ```
   - **Django :**
     ```bash
     django-admin --version
     ```

2. **Problèmes fréquents :**
   - Si `django-admin` ne fonctionne pas, utilisez :
     ```bash
     export PATH=$PATH:~/.local/bin
     ```
   - Si des dépendances manquent, installez-les avec `pip3`.


