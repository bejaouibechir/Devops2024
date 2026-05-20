import subprocess
import re
from datetime import datetime, timedelta
from trumpito_core.logger import get_logger
from trumpito_modules.base import TrumpitoModule

logger = get_logger("trumpito.packages")


class Module(TrumpitoModule):

    name = "packages"
    description = "Historique APT et détection de paquets cassés"
    requires_root = True
    version = "1.0.0"

    def __init__(self):
        super().__init__()
        self.history_days = 30

    def run(self) -> dict:
        data = {
            "recent_installed": self._get_recent_installed(),
            "recent_removed":   self._get_recent_removed(),
            "recent_upgraded":  self._get_recent_upgraded(),
            "broken":           self._get_broken_packages(),
            "pending":          self._get_pending_upgrades(),
            "summary":          {},
        }
        data["summary"] = {
            "total_installed": len(data["recent_installed"]),
            "total_removed":   len(data["recent_removed"]),
            "total_upgraded":  len(data["recent_upgraded"]),
            "total_broken":    len(data["broken"]),
            "total_pending":   len(data["pending"]),
        }
        return data

    def format_output(self, data: dict) -> str:
        lines = []

        s = data.get("summary", {})
        lines.append(f"  Résumé ({self.history_days} derniers jours) : "
                     f"{s.get('total_installed', 0)} installés | "
                     f"{s.get('total_removed', 0)} supprimés | "
                     f"{s.get('total_upgraded', 0)} mis à jour")
        lines.append("")

        broken = data.get("broken", [])
        if broken:
            lines.append("  🔴 Paquets cassés :")
            lines.append(f"    {'Paquet':<35} {'Statut'}")
            lines.append(f"    {'─'*35} {'─'*25}")
            for pkg in broken:
                lines.append(f"    {pkg['name']:<35} {pkg['status']}")
        else:
            lines.append("  ✅ Aucun paquet cassé")
        lines.append("")

        pending = data.get("pending", [])
        if pending:
            lines.append("  📦 Mises à jour disponibles :")
            lines.append(f"    {'Paquet':<35} {'Version actuelle':<20} {'Version disponible'}")
            lines.append(f"    {'─'*35} {'─'*20} {'─'*20}")
            for pkg in pending:
                lines.append(
                    f"    {pkg['name']:<35} "
                    f"{pkg['current']:<20} "
                    f"{pkg['available']}"
                )
        else:
            lines.append("  ✅ Système à jour")
        lines.append("")

        lines.append("  🟢 Récemment installés :")
        lines.append(f"    {'Paquet':<35} {'Version':<20} {'Date'}")
        lines.append(f"    {'─'*35} {'─'*20} {'─'*22}")
        for pkg in data.get("recent_installed", []):
            lines.append(
                f"    {pkg['name']:<35} "
                f"{pkg['version']:<20} "
                f"{pkg['date']}"
            )
        lines.append("")

        upgraded = data.get("recent_upgraded", [])
        if upgraded:
            lines.append("  🔄 Récemment mis à jour :")
            lines.append(f"    {'Paquet':<35} {'Ancien':<20} {'Nouveau':<20} {'Date'}")
            lines.append(f"    {'─'*35} {'─'*20} {'─'*20} {'─'*22}")
            for pkg in upgraded:
                lines.append(
                    f"    {pkg['name']:<35} "
                    f"{pkg['old_version']:<20} "
                    f"{pkg['new_version']:<20} "
                    f"{pkg['date']}"
                )
        lines.append("")

        removed = data.get("recent_removed", [])
        if removed:
            lines.append("  🗑️  Récemment supprimés :")
            lines.append(f"    {'Paquet':<35} {'Date'}")
            lines.append(f"    {'─'*35} {'─'*22}")
            for pkg in removed:
                lines.append(f"    {pkg['name']:<35} {pkg['date']}")

        return "\n".join(lines)

    def _get_dpkg_log(self) -> list[str]:
        try:
            with open("/var/log/dpkg.log", "r") as f:
                return f.readlines()
        except FileNotFoundError:
            logger.error("/var/log/dpkg.log introuvable")
            return []

    def _parse_dpkg_log(self, action: str) -> list[dict]:
        entries = []
        cutoff = datetime.now() - timedelta(days=self.history_days)
        log_lines = self._get_dpkg_log()

        for line in log_lines:
            try:
                parts = line.strip().split()
                if len(parts) < 4:
                    continue
                date_str = f"{parts[0]} {parts[1]}"
                entry_date = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S")
                if entry_date < cutoff:
                    continue
                if action not in line:
                    continue

                # Format "install ok installed" : date heure install ok installed paquet version
                if action == "install ok installed" and len(parts) >= 7:
                    pkg_name = parts[5]
                    version = parts[6]
                # Format "remove ok" : date heure remove ok paquet version
                elif action == "remove ok" and len(parts) >= 6:
                    pkg_name = parts[4]
                    version = parts[5]
                else:
                    continue

                entries.append({
                    "name":    pkg_name,
                    "version": version,
                    "date":    date_str,
                })
            except (ValueError, IndexError) as e:
                logger.debug("Erreur parsing dpkg.log : %s", e)
                continue
        return entries

    def _get_recent_installed(self) -> list[dict]:
        return self._parse_dpkg_log("install ok installed")

    def _get_recent_removed(self) -> list[dict]:
        return self._parse_dpkg_log("remove ok")

    def _get_recent_upgraded(self) -> list[dict]:
        entries = []
        cutoff = datetime.now() - timedelta(days=self.history_days)
        log_lines = self._get_dpkg_log()

        for line in log_lines:
            try:
                parts = line.strip().split()
                if len(parts) < 6:
                    continue
                date_str = f"{parts[0]} {parts[1]}"
                entry_date = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S")
                if entry_date < cutoff:
                    continue
                # Format upgrade : date heure upgrade paquet version_avant version_apres
                if parts[2] != "upgrade":
                    continue

                pkg_name   = parts[3]
                old_version = parts[4]
                new_version = parts[5]

                entries.append({
                    "name":        pkg_name,
                    "old_version": old_version,
                    "new_version": new_version,
                    "date":        date_str,
                })
            except (ValueError, IndexError) as e:
                logger.debug("Erreur parsing upgrade : %s", e)
                continue
        return entries

    def _parse_upgrade_versions(self, version_str: str) -> tuple[str, str]:
        if " -> " in version_str:
            parts = version_str.split(" -> ")
            return parts[0].strip(), parts[1].strip()
        return "—", version_str

    def _get_broken_packages(self) -> list[dict]:
        broken = []
        try:
            result = subprocess.run(
                ["dpkg", "--configure", "-a", "--dry-run"],
                capture_output=True,
                text=True,
                timeout=15,
            )
            output = result.stdout + result.stderr
            for line in output.splitlines():
                if "unpacked" in line or "half-installed" in line:
                    match = re.search(r"(\S+)", line.split()[-1] if line.split() else "")
                    if match:
                        broken.append({
                            "name":   match.group(1),
                            "status": "half-installed",
                        })

            result2 = subprocess.run(
                ["apt-get", "check"],
                capture_output=True,
                text=True,
                timeout=15,
            )
            for line in result2.stdout.splitlines():
                if "is already" in line or "depends on" in line:
                    pkg = line.split()[0] if line.split() else "—"
                    broken.append({
                        "name":   pkg,
                        "status": "dépendances cassées",
                    })
        except Exception as e:
            logger.error("Erreur détection paquets cassés : %s", e)
        return broken

    def _get_pending_upgrades(self) -> list[dict]:
        pending = []
        try:
            result = subprocess.run(
                ["apt", "list", "--upgradable"],
                capture_output=True,
                text=True,
                timeout=30,
            )
            if result.returncode != 0:
                return []
            for line in result.stdout.strip().splitlines():
                if "/" not in line:
                    continue
                parsed = self._parse_upgradable_line(line)
                if parsed:
                    pending.append(parsed)
        except Exception as e:
            logger.error("Erreur apt list --upgradable : %s", e)
        return pending

    def _parse_upgradable_line(self, line: str) -> dict | None:
        try:
            match = re.match(
                r"^(\S+)/\S+\s+(\S+)\s+\S+\s+\[upgradable from: (\S+)\]",
                line,
            )
            if match:
                return {
                    "name":      match.group(1),
                    "available": match.group(2),
                    "current":   match.group(3),
                }
        except Exception as e:
            logger.debug("Erreur parsing upgradable : %s", e)
        return None
