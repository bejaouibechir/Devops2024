import sys
import argparse
from trumpito_core.logger import get_logger
from trumpito_core.config import TrumpitoConfig
from trumpito_core.permissions import check_command_permissions
from trumpito_core.reporter import TrumpitoReporter
from trumpito_core.module_loader import ModuleLoader

logger = get_logger("trumpito.cli")

VERSION = "1.0.0"

BANNER = """
==========================================================
  _______ _____  _    _ __  __ _____ _____ _______ ____  
 |__   __|  __ \\| |  | |  \\/  |  __ \\_   _|__   __/ __ \\ 
    | |  | |__) | |  | | \\  / | |__) || |    | | | |  | |
    | |  |  _  /| |  | | |/\\| |  ___/ | |    | | | |  | |
    | |  | | \\ \\| |__| | |  | | |    _| |_   | | | |__| |
    |_|  |_|  \\_\\\\____/|_|  |_|_|   |_____|  |_|  \\____/ 
                                                         
          MAKE YOUR CLI GREAT AGAIN 🇺🇸
==========================================================
> Version: """ + VERSION + """
> Status: Winning
> Message: "We're going to build the best code, 
            and it's going to be beautiful."
----------------------------------------------------------
"""


def print_banner():
    print(BANNER)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="trumpito",
        description="Trumpito - System diagnostic and audit tool for Ubuntu",
        add_help=True,
    )
    parser.add_argument("--version", action="version", version=f"trumpito {VERSION}")
    parser.add_argument("--format", choices=["text", "json"], default="text", help="Format de sortie du rapport")
    parser.add_argument("--output", type=str, default=None, help="Fichier de sortie (chemin complet)")
    parser.add_argument("--no-banner", action="store_true", help="Désactiver la bannière")

    subparsers = parser.add_subparsers(dest="command")

    subparsers.add_parser("scan", help="Diagnostic global du système")
    subparsers.add_parser("report", help="Génère un rapport détaillé")

    module_parser = subparsers.add_parser("module", help="Gestion des modules")
    module_sub = module_parser.add_subparsers(dest="module_action")
    module_sub.add_parser("list", help="Liste les modules disponibles")

    module_run = module_sub.add_parser("run", help="Exécute un module spécifique")
    module_run.add_argument("module_name", type=str, help="Nom du module à exécuter")

    return parser


def handle_scan(loader: ModuleLoader, reporter: TrumpitoReporter, args: argparse.Namespace):
    print("\n🔍 Scan en cours...\n")
    results = loader.run_all()
    output = reporter.generate(results, fmt=args.format)
    print(output)
    saved = reporter.save(output, fmt=args.format)
    if saved:
        print(f"\n💾 Rapport sauvegardé : {saved}\n")
    if args.output:
        try:
            with open(args.output, "w") as f:
                f.write(output)
            print(f"💾 Rapport exporté : {args.output}\n")
        except Exception as e:
            logger.error("Erreur export fichier : %s", e)


def handle_report(loader: ModuleLoader, reporter: TrumpitoReporter, args: argparse.Namespace):
    print("\n📊 Génération du rapport...\n")
    results = loader.run_all()
    output = reporter.generate(results, fmt=args.format)
    print(output)
    saved = reporter.save(output, fmt=args.format)
    if saved:
        print(f"\n💾 Rapport sauvegardé : {saved}\n")
    if args.output:
        try:
            with open(args.output, "w") as f:
                f.write(output)
            print(f"💾 Rapport exporté : {args.output}\n")
        except Exception as e:
            logger.error("Erreur export fichier : %s", e)


def handle_module_list(loader: ModuleLoader):
    modules = loader.list_modules()
    print("\n📦 Modules disponibles :\n")
    print(f"  {'Nom':<12} {'Version':<10} {'Root':<6} {'Statut':<10}Description")
    print(f"  {'─'*12} {'─'*10} {'─'*6} {'─'*10} {'─'*30}")
    for m in modules:
        status = "✅ actif" if m["enabled"] else "⛔ désactivé"
        root = "oui" if m["requires_root"] else "non"
        print(f"  {m['name']:<12} {m['version']:<10} {root:<6} {status:<10} {m['description']}")
    print()


def handle_module_run(loader: ModuleLoader, reporter: TrumpitoReporter, args: argparse.Namespace):
    name = args.module_name
    print(f"\n🔧 Exécution du module : {name}\n")
    result = loader.run_one(name)
    if result is None:
        sys.exit(1)
    output = reporter.generate([result], fmt=args.format)
    print(output)
    if args.output:
        try:
            with open(args.output, "w") as f:
                f.write(output)
            print(f"\n💾 Rapport exporté : {args.output}\n")
        except Exception as e:
            logger.error("Erreur export fichier : %s", e)


def main():
    parser = build_parser()
    args = parser.parse_args()

    if not args.no_banner:
        print_banner()

    if not args.command:
        parser.print_help()
        sys.exit(0)

    command_str = args.command
    if args.command == "module" and args.module_action == "run":
        command_str = f"module run {args.module_name}"

    if not check_command_permissions(command_str):
        sys.exit(1)

    config = TrumpitoConfig()
    loader = ModuleLoader(config)

    if args.command == "scan":
        reporter = TrumpitoReporter(config)
        handle_scan(loader, reporter, args)

    elif args.command == "report":
        reporter = TrumpitoReporter(config)
        handle_report(loader, reporter, args)

    elif args.command == "module":
        if args.module_action == "list":
            handle_module_list(loader)
        elif args.module_action == "run":
            reporter = TrumpitoReporter(config)
            handle_module_run(loader, reporter, args)
        else:
            parser.parse_args(["module", "--help"])
            sys.exit(0)

    else:
        parser.print_help()
        sys.exit(0)
