FROM python:3.11-slim

# Métadonnées
LABEL maintainer="workshop@k8s.local"
LABEL description="Backend Flask pour MySQL Employee Management"

# Définir le répertoire de travail
WORKDIR /app

# Copier les dépendances
COPY requirements.txt .

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code source
COPY app.py .

# Créer un utilisateur non-root
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Exposer le port
EXPOSE 5000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Commande de démarrage
CMD ["python", "app.py"]
