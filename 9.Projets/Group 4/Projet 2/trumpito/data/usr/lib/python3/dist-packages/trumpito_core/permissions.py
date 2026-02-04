import os
import sys
import subprocess
from trumpito_core.logger import get_logger

logger = get_logger("trumpito.permissions")

COMMANDS_REQUIRING_ROOT = [
    "scan",
    "module run disk",
    "module run services",
    "module run network",
    "module run packages",
]


def is_root() -> bool:
    return os.geteuid() == 0


def check_command_permissions(command: str) -> bool:
    if is_root():
        return True

    for cmd in COMMANDS_REQUIRING_ROOT:
        if command.startswith(cmd):
            logger.warning("Commande '%s' nécessite sudo", command)
            print(f"\n⚠️  La commande '{command}' nécessite des droits root.")
            print("    Réessayez avec : sudo trumpito " + command + "\n")
            return False

    return True


def check_binary_exists(binary: str) -> bool:
    try:
        subprocess.run(
            ["which", binary],
            capture_output=True,
            check=True,
        )
        return True
    except subprocess.CalledProcessError:
        logger.warning("Binaire introuvable : %s", binary)
        return False


def require_binaries(binaries: list[str]) -> list[str]:
    missing = [b for b in binaries if not check_binary_exists(b)]
    if missing:
        logger.error("Binaires manquants : %s", missing)
    return missing
