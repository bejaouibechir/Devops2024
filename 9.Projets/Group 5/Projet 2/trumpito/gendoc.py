import os
import pathlib
import sys
from typing import List, Set

def get_code_extensions() -> Set[str]:
    """Retourne les extensions de fichiers considérés comme code source"""
    return {
        '.py', '.js', '.ts', '.jsx', '.tsx', '.java', '.cpp', '.c', '.h', '.hpp',
        '.cs', '.php', '.rb', '.go', '.rs', '.swift', '.kt', '.scala', '.m', '.mm',
        '.html', '.css', '.scss', '.less', '.json', '.xml', '.yml', '.yaml', '.toml',
        '.md', '.txt', '.sql', '.sh', '.bash', '.bat', '.ps1', '.vue', '.dart'
    }

def should_ignore(path: str) -> bool:
    """Détermine si un chemin doit être ignoré"""
    ignore_patterns = [
        '__pycache__', '.git', '.svn', '.hg', '.idea', '.vscode',
        'node_modules', 'dist', 'build', 'venv', 'env', '.env',
        '.pytest_cache', '.mypy_cache', 'coverage', '.coverage'
    ]
    return any(pattern in path for pattern in ignore_patterns)

def get_tree_representation(root_dir: str, prefix: str = "", is_last: bool = True) -> str:
    """Génère une représentation arborescente d'un répertoire"""
    path = pathlib.Path(root_dir)
    name = path.name if path.name != "." else os.path.basename(os.path.abspath(root_dir))
    
    # Déterminer le préfixe pour l'élément courant
    connector = "└── " if is_last else "├── "
    result = prefix + connector + name + "\n"
    
    # Préfixe pour les enfants
    new_prefix = prefix + ("    " if is_last else "│   ")
    
    try:
        # Lister tous les éléments du répertoire
        items = sorted([item for item in path.iterdir() if not should_ignore(str(item))])
        
        for i, item in enumerate(items):
            is_last_item = i == len(items) - 1
            if item.is_dir():
                result += get_tree_representation(str(item), new_prefix, is_last_item)
            else:
                result += new_prefix + ("└── " if is_last_item else "├── ") + item.name + "\n"
    except PermissionError:
        result += new_prefix + "└── [Permission denied]\n"
    
    return result

def get_file_content(file_path: str) -> str:
    """Lit le contenu d'un fichier en gérant les encodages"""
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            return f.read()
    except UnicodeDecodeError:
        try:
            with open(file_path, 'r', encoding='latin-1', errors='ignore') as f:
                return f.read()
        except Exception:
            return "[Erreur: Impossible de lire le fichier]"
    except Exception as e:
        return f"[Erreur: {str(e)}]"

def process_directory(root_path: str, output_file: str = "code_structure.txt"):
    """Traverse récursivement le projet et génère le rapport"""
    code_extensions = get_code_extensions()
    
    # Obtenir le chemin absolu du répertoire racine
    root_path = os.path.abspath(root_path)
    
    # Collecter tous les fichiers de code
    code_files = []
    for dirpath, dirnames, filenames in os.walk(root_path):
        # Filtrer les dossiers à ignorer
        dirnames[:] = [d for d in dirnames if not should_ignore(os.path.join(dirpath, d))]
        
        for filename in filenames:
            file_path = os.path.join(dirpath, filename)
            if should_ignore(file_path):
                continue
            
            ext = os.path.splitext(filename)[1].lower()
            if ext in code_extensions or ext == '':  # Inclure les fichiers sans extension
                code_files.append(file_path)
    
    # Trier les fichiers par chemin pour une meilleure lisibilité
    code_files.sort()
    
    # Générer le rapport
    with open(output_file, 'w', encoding='utf-8') as f:
        # 1. Arborescence du projet
        f.write("=" * 80 + "\n")
        f.write("ARBORESCENCE DU PROJET\n")
        f.write("=" * 80 + "\n\n")
        f.write(get_tree_representation(root_path))
        f.write("\n" + "=" * 80 + "\n\n")
        
        # 2. Contenu des fichiers de code
        f.write("CONTENU DES FICHIERS DE CODE\n")
        f.write("=" * 80 + "\n\n")
        
        for i, file_path in enumerate(code_files, 1):
            # Calculer le chemin relatif
            rel_path = os.path.relpath(file_path, root_path)
            
            # Section pour chaque fichier
            f.write(f"FICHIER {i}: {rel_path}\n")
            f.write("-" * 80 + "\n")
            
            # Lire et écrire le contenu
            content = get_file_content(file_path)
            f.write(content)
            
            # Ajouter une séparation si ce n'est pas le dernier fichier
            if i < len(code_files):
                f.write("\n\n" + "=" * 80 + "\n\n")
    
    print(f"Rapport généré avec succès dans: {output_file}")
    print(f"Nombre de fichiers traités: {len(code_files)}")
    print(f"Racine du projet: {root_path}")

def main():
    """Fonction principale"""
    # Déterminer le répertoire courant si aucun argument n'est fourni
    if len(sys.argv) > 1:
        root_dir = sys.argv[1]
    else:
        root_dir = "."
    
    # Vérifier que le chemin existe
    if not os.path.exists(root_dir):
        print(f"Erreur: Le chemin '{root_dir}' n'existe pas.")
        sys.exit(1)
    
    if not os.path.isdir(root_dir):
        print(f"Erreur: '{root_dir}' n'est pas un répertoire.")
        sys.exit(1)
    
    # Nom du fichier de sortie
    output_file = "code_structure_report.txt"
    
    try:
        process_directory(root_dir, output_file)
    except KeyboardInterrupt:
        print("\nInterrompu par l'utilisateur.")
        sys.exit(0)
    except Exception as e:
        print(f"Une erreur est survenue: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()