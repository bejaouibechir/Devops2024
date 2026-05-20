#!/bin/bash

##############################################################################
# Script de déploiement MySQL sur Kubernetes
# Description: Déploie une instance MySQL avec StatefulSet, ConfigMap et Services
##############################################################################

set -e  # Arrêter en cas d'erreur

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher des messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Fonction pour vérifier si kubectl est installé
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl n'est pas installé. Veuillez l'installer avant de continuer."
        exit 1
    fi
    log_success "kubectl est installé"
}

# Fonction pour vérifier la connexion au cluster
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Impossible de se connecter au cluster Kubernetes"
        exit 1
    fi
    log_success "Connexion au cluster Kubernetes établie"
}

# Fonction pour afficher les informations du cluster
show_cluster_info() {
    log_info "Informations du cluster:"
    kubectl cluster-info | head -n 2
    echo ""
}

# Fonction pour déployer les ressources
deploy_resources() {
    local yaml_dir="$1"
    
    log_info "Déploiement des ressources Kubernetes depuis: $yaml_dir"
    echo ""
    
    # 1. Créer le namespace
    log_info "Étape 1/5: Création du namespace..."
    kubectl apply -f "$yaml_dir/00-namespace.yaml"
    log_success "Namespace créé"
    echo ""
    
    # 2. Créer les secrets
    log_info "Étape 2/5: Création des secrets..."
    kubectl apply -f "$yaml_dir/01-secret.yaml"
    log_success "Secrets créés"
    echo ""
    
    # 3. Créer le ConfigMap
    log_info "Étape 3/5: Création du ConfigMap..."
    kubectl apply -f "$yaml_dir/02-configmap.yaml"
    log_success "ConfigMap créé"
    echo ""
    
    # 4. Créer le StatefulSet
    log_info "Étape 4/5: Création du StatefulSet MySQL..."
    kubectl apply -f "$yaml_dir/03-statefulset.yaml"
    log_success "StatefulSet créé"
    echo ""
    
    # 5. Créer les services
    log_info "Étape 5/5: Création des services..."
    kubectl apply -f "$yaml_dir/04-services.yaml"
    log_success "Services créés"
    echo ""
}

# Fonction pour attendre que le pod soit prêt
wait_for_mysql() {
    log_info "Attente du démarrage de MySQL (timeout: 300s)..."
    
    if kubectl wait --for=condition=ready pod -l app=mysql -n mysql-app --timeout=300s; then
        log_success "MySQL est prêt !"
    else
        log_error "Timeout: MySQL n'a pas démarré dans les temps"
        log_warning "Vérifiez les logs avec: kubectl logs -n mysql-app -l app=mysql"
        return 1
    fi
}

# Fonction pour afficher le statut des ressources
show_status() {
    echo ""
    log_info "═══════════════════════════════════════════════════════"
    log_info "État des ressources déployées"
    log_info "═══════════════════════════════════════════════════════"
    echo ""
    
    log_info "Namespaces:"
    kubectl get namespace mysql-app
    echo ""
    
    log_info "StatefulSet:"
    kubectl get statefulset -n mysql-app
    echo ""
    
    log_info "Pods:"
    kubectl get pods -n mysql-app -o wide
    echo ""
    
    log_info "Services:"
    kubectl get services -n mysql-app
    echo ""
    
    log_info "PersistentVolumeClaims:"
    kubectl get pvc -n mysql-app
    echo ""
    
    log_info "Secrets:"
    kubectl get secrets -n mysql-app
    echo ""
    
    log_info "ConfigMaps:"
    kubectl get configmaps -n mysql-app
    echo ""
}

# Fonction pour tester la connexion MySQL
test_mysql_connection() {
    log_info "Test de connexion à MySQL..."
    
    POD_NAME=$(kubectl get pods -n mysql-app -l app=mysql -o jsonpath='{.items[0].metadata.name}')
    
    if [ -z "$POD_NAME" ]; then
        log_error "Aucun pod MySQL trouvé"
        return 1
    fi
    
    log_info "Test de connexion sur le pod: $POD_NAME"
    
    if kubectl exec -n mysql-app "$POD_NAME" -- mysql -uroot -p'MySecureP@ssw0rd2024!' -e "SELECT 1" &> /dev/null; then
        log_success "Connexion MySQL réussie !"
        
        # Afficher les bases de données
        log_info "Bases de données disponibles:"
        kubectl exec -n mysql-app "$POD_NAME" -- mysql -uroot -p'MySecureP@ssw0rd2024!' -e "SHOW DATABASES;"
        
        # Vérifier la table employees
        log_info "Contenu de la table employees:"
        kubectl exec -n mysql-app "$POD_NAME" -- mysql -uroot -p'MySecureP@ssw0rd2024!' -D businessdb -e "SELECT * FROM employees;"
    else
        log_error "Échec de la connexion MySQL"
        return 1
    fi
}

# Fonction pour afficher les informations de connexion
show_connection_info() {
    echo ""
    log_info "═══════════════════════════════════════════════════════"
    log_info "Informations de connexion MySQL"
    log_info "═══════════════════════════════════════════════════════"
    echo ""
    
    log_info "Depuis l'intérieur du cluster:"
    echo "  Host: mysql-service.mysql-app.svc.cluster.local"
    echo "  Port: 3306"
    echo "  Database: businessdb"
    echo "  User: appuser"
    echo "  Password: AppU5er@2024"
    echo ""
    
    log_info "Depuis l'extérieur du cluster (NodePort):"
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
    echo "  Host: $NODE_IP (ou l'IP externe de votre node)"
    echo "  Port: 30306"
    echo "  Database: businessdb"
    echo "  User: appuser"
    echo "  Password: AppU5er@2024"
    echo ""
    
    log_info "Commande de connexion (depuis un pod dans le cluster):"
    echo "  mysql -h mysql-service.mysql-app.svc.cluster.local -u appuser -p'AppU5er@2024' businessdb"
    echo ""
    
    log_info "Port-forward pour accès local:"
    echo "  kubectl port-forward -n mysql-app svc/mysql-service 3306:3306"
    echo "  mysql -h 127.0.0.1 -P 3306 -u appuser -p'AppU5er@2024' businessdb"
    echo ""
}

# Fonction pour afficher les commandes utiles
show_useful_commands() {
    log_info "═══════════════════════════════════════════════════════"
    log_info "Commandes utiles"
    log_info "═══════════════════════════════════════════════════════"
    echo ""
    echo "# Voir les logs MySQL:"
    echo "kubectl logs -n mysql-app -l app=mysql -f"
    echo ""
    echo "# Se connecter au pod MySQL:"
    echo "kubectl exec -it -n mysql-app mysql-0 -- bash"
    echo ""
    echo "# Redémarrer MySQL:"
    echo "kubectl rollout restart statefulset/mysql -n mysql-app"
    echo ""
    echo "# Supprimer tout le déploiement:"
    echo "./deploy-mysql.sh cleanup"
    echo ""
}

# Fonction de nettoyage
cleanup() {
    log_warning "Suppression de toutes les ressources MySQL..."
    
    read -p "Êtes-vous sûr de vouloir supprimer toutes les ressources ? (oui/non): " confirmation
    
    if [ "$confirmation" != "oui" ]; then
        log_info "Annulation de la suppression"
        exit 0
    fi
    
    log_info "Suppression des services..."
    kubectl delete -f 04-services.yaml --ignore-not-found=true
    
    log_info "Suppression du StatefulSet..."
    kubectl delete -f 03-statefulset.yaml --ignore-not-found=true
    
    log_info "Suppression du ConfigMap..."
    kubectl delete -f 02-configmap.yaml --ignore-not-found=true
    
    log_info "Suppression des secrets..."
    kubectl delete -f 01-secret.yaml --ignore-not-found=true
    
    log_info "Suppression des PVCs..."
    kubectl delete pvc -n mysql-app --all
    
    log_info "Suppression du namespace..."
    kubectl delete -f 00-namespace.yaml --ignore-not-found=true
    
    log_success "Toutes les ressources ont été supprimées"
}

# Fonction principale
main() {
    echo ""
    log_info "═══════════════════════════════════════════════════════"
    log_info "Script de déploiement MySQL sur Kubernetes"
    log_info "═══════════════════════════════════════════════════════"
    echo ""
    
    # Vérifier les prérequis
    check_kubectl
    check_cluster
    show_cluster_info
    
    # Définir le répertoire des fichiers YAML
    YAML_DIR="${1:-.}"
    
    if [ ! -d "$YAML_DIR" ]; then
        log_error "Le répertoire $YAML_DIR n'existe pas"
        exit 1
    fi
    
    # Déployer les ressources
    deploy_resources "$YAML_DIR"
    
    # Attendre que MySQL soit prêt
    wait_for_mysql
    
    # Afficher le statut
    show_status
    
    # Tester la connexion
    test_mysql_connection
    
    # Afficher les informations de connexion
    show_connection_info
    
    # Afficher les commandes utiles
    show_useful_commands
    
    log_success "Déploiement terminé avec succès !"
}

# Point d'entrée du script
case "${1:-deploy}" in
    deploy)
        main "${2:-.}"
        ;;
    cleanup)
        cleanup
        ;;
    status)
        show_status
        ;;
    test)
        test_mysql_connection
        ;;
    *)
        echo "Usage: $0 {deploy|cleanup|status|test} [yaml_directory]"
        echo ""
        echo "Commands:"
        echo "  deploy [dir]  - Déploie MySQL (défaut: répertoire courant)"
        echo "  cleanup       - Supprime toutes les ressources"
        echo "  status        - Affiche le statut des ressources"
        echo "  test          - Teste la connexion MySQL"
        exit 1
        ;;
esac
