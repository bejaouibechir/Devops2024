import subprocess
from trumpito_core.logger import get_logger
from trumpito_modules.base import TrumpitoModule

logger = get_logger("trumpito.services")


class Module(TrumpitoModule):

    name = "services"
    description = "Analyse des services systemd et leur état"
    requires_root = True
    version = "1.0.0"

    def __init__(self):
        super().__init__()
        self.exclude_patterns = ["systemd-*"]

    def run(self) -> dict:
        data = {
            "active":   self._get_services_by_state("active"),
            "failed":   self._get_services_by_state("failed"),
            "inactive": self._get_services_by_state("inactive"),
            "boot_slow": self._get_slow_boot_services(),
            "summary":  {},
        }
        data["summary"] = {
            "total_active":   len(data["active"]),
            "total_failed":   len(data["failed"]),
            "total_inactive": len(data["inactive"]),
        }
        return data

    def format_output(self, data: dict) -> str:
        lines = []

        s = data.get("summary", {})
        lines.append(f"  Résumé : {s.get('total_active', 0)} actifs | "
                     f"{s.get('total_failed', 0)} en échec | "
                     f"{s.get('total_inactive', 0)} inactifs")
        lines.append("")

        failed = data.get("failed", [])
        if failed:
            lines.append("  🔴 Services en échec :")
            lines.append(f"    {'Service':<40} {'Depuis':<20}")
            lines.append(f"    {'─'*40} {'─'*20}")
            for svc in failed:
                lines.append(f"    {svc['name']:<40} {svc['since']:<20}")
        else:
            lines.append("  ✅ Aucun service en échec")
        lines.append("")

        lines.append("  🟢 Services actifs :")
        lines.append(f"    {'Service':<40} {'PID':<8} {'Depuis':<20}")
        lines.append(f"    {'─'*40} {'─'*8} {'─'*20}")
        for svc in data.get("active", []):
            lines.append(f"    {svc['name']:<40} {svc['pid']:<8} {svc['since']:<20}")
        lines.append("")

        slow = data.get("boot_slow", [])
        if slow:
            lines.append("  🐢 Services à démarrage lent :")
            lines.append(f"    {'Service':<40} {'Durée':<15}")
            lines.append(f"    {'─'*40} {'─'*15}")
            for svc in slow:
                lines.append(f"    {svc['name']:<40} {svc['time']:<15}")
        else:
            lines.append("  ✅ Aucun service à démarrage lent")

        return "\n".join(lines)

    def _get_services_by_state(self, state: str) -> list[dict]:
        try:
            # Récupérer la liste des services
            result = subprocess.run(
                ["systemctl", "list-units", "--type=service",
                 f"--state={state}", "--no-legend", "--no-pager"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode != 0:
                return []

            # Extraire les noms de services
            service_names = []
            for line in result.stdout.strip().splitlines():
                parts = line.split()
                if len(parts) < 3:
                    continue
                name = parts[0]
                if self._is_excluded(name):
                    continue
                service_names.append(name)

            if not service_names:
                return []

            # Récupérer MainPID et ActiveSince pour tous les services en une seule commande
            properties = self._get_services_properties(service_names)

            services = []
            for name in service_names:
                props = properties.get(name, {})
                services.append({
                    "name":  name,
                    "state": state,
                    "pid":   props.get("MainPID", "—"),
                    "since": props.get("ActiveSince", "—"),
                })
            return services
        except (subprocess.TimeoutExpired, Exception) as e:
            logger.error("Erreur systemctl list-units (%s) : %s", state, e)
            return []

    def _get_services_properties(self, service_names: list[str]) -> dict:
        """Récupère MainPID et Since via systemctl status (fiable sur EC2 où show n'expose pas ActiveSince)"""
        import re
        properties = {}
        try:
            for name in service_names:
                result = subprocess.run(
                    ["systemctl", "status", name, "--no-pager", "-l"],
                    capture_output=True,
                    text=True,
                    timeout=3,
                )
                # systemctl status retourne exit code 3 si inactive, on parse quoi qu'il en soit
                props = {}
                for line in result.stdout.splitlines():
                    stripped = line.strip()

                    # Main PID: 1097 (sshd)
                    if stripped.startswith("Main PID:"):
                        match = re.search(r"Main PID:\s*(\d+)", stripped)
                        if match:
                            props["MainPID"] = match.group(1)

                    # Active: active (running) since Mon 2026-02-02 23:19:23 UTC; 18min ago
                    elif stripped.startswith("Active:") and "since" in stripped:
                        match = re.search(r"since\s+\w+\s+([\d-]+)\s+([\d:]+)", stripped)
                        if match:
                            date_str = match.group(1)   # 2026-02-02
                            time_str = match.group(2)   # 23:19:23
                            dd = date_str.split("-")[2]
                            mm = date_str.split("-")[1]
                            hh_mm = time_str[:5]
                            props["ActiveSince"] = f"{dd}-{mm} {hh_mm}"

                if not props.get("MainPID"):
                    props["MainPID"] = "—"
                if not props.get("ActiveSince"):
                    props["ActiveSince"] = "—"
                properties[name] = props

        except Exception as e:
            logger.error("Erreur systemctl status : %s", e)
        return properties

    def _format_since(self, date_str: str) -> str:
        """Convertit 'Mon 2 Feb 2026 19:04:20 UTC' en '02-feb 19:04'"""
        if not date_str:
            return "—"
        try:
            # Supprimer le jour de la semaine au début
            parts = date_str.split()
            # Format attendu : [Jour] [Jour_num] [Mois] [Année] [Heure] [TZ]
            if len(parts) >= 5:
                day   = parts[1].zfill(2)
                month = parts[2][:3].lower()
                time  = parts[4][:5]  # "19:04:20" → "19:04"
                return f"{day}-{month} {time}"
        except (IndexError, ValueError):
            pass
        return date_str[:16] if len(date_str) > 16 else date_str

    def _get_slow_boot_services(self, threshold_ms: int = 1000) -> list[dict]:
        try:
            result = subprocess.run(
                ["systemd-analyze", "blame", "--no-pager"],
                capture_output=True,
                text=True,
                timeout=15,
            )
            if result.returncode != 0:
                return []
            return self._parse_blame(result.stdout, threshold_ms)
        except (subprocess.TimeoutExpired, Exception) as e:
            logger.error("Erreur systemd-analyze blame : %s", e)
            return []

    def _parse_blame(self, output: str, threshold_ms: int) -> list[dict]:
        slow = []
        for line in output.strip().splitlines():
            parts = line.split()
            if len(parts) < 4:
                continue
            time_str = parts[0]
            name = parts[-1]
            if self._is_excluded(name):
                continue
            ms = self._parse_time_to_ms(time_str)
            if ms and ms > threshold_ms:
                slow.append({
                    "name": name,
                    "time": time_str,
                    "ms":   ms,
                })
        slow.sort(key=lambda x: x["ms"], reverse=True)
        return slow[:10]

    @staticmethod
    def _parse_time_to_ms(time_str: str) -> int | None:
        try:
            if "min" in time_str:
                parts = time_str.replace("min", "").replace("s", "").split(".")
                return int(float(parts[0]) * 60000 + float(parts[1]) * 1000) if len(parts) > 1 else int(float(parts[0]) * 60000)
            if "s" in time_str:
                return int(float(time_str.replace("s", "")) * 1000)
            if "ms" in time_str:
                return int(time_str.replace("ms", ""))
        except (ValueError, IndexError):
            return None
        return None

    def _is_excluded(self, name: str) -> bool:
        for pattern in self.exclude_patterns:
            prefix = pattern.replace("*", "")
            if name.startswith(prefix):
                return True
        return False
