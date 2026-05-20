import os
import shutil
import subprocess
from trumpito_core.logger import get_logger
from trumpito_modules.base import TrumpitoModule

logger = get_logger("trumpito.disk")


class Module(TrumpitoModule):

    name = "disk"
    description = "Analyse occupation disque et détection des fuites"
    requires_root = True
    version = "1.0.0"

    def __init__(self):
        super().__init__()
        self.max_depth = 3
        self.exclude_dirs = {"/proc", "/sys", "/dev", "/run", "/snap"}

    def run(self) -> dict:
        data = {
            "partitions": self._get_partitions(),
            "top_directories": self._get_top_directories("/", self.max_depth),
            "leaks": self._detect_leaks(),
        }
        return data

    def format_output(self, data: dict) -> str:
        lines = []

        lines.append("  Partitions :")
        lines.append(f"    {'Montage':<20} {'Taille':<12} {'Utilisé':<12} {'Libre':<12} {'%':<6}")
        lines.append(f"    {'─'*20} {'─'*12} {'─'*12} {'─'*12} {'─'*6}")
        for p in data.get("partitions", []):
            lines.append(
                f"    {p['mountpoint']:<20} "
                f"{p['total_h']:<12} "
                f"{p['used_h']:<12} "
                f"{p['free_h']:<12} "
                f"{p['percent']}%"
            )

        lines.append("")
        lines.append("  Top répertoires par taille :")
        lines.append(f"    {'Répertoire':<40} {'Taille':<12}")
        lines.append(f"    {'─'*40} {'─'*12}")
        for d in data.get("top_directories", []):
            lines.append(f"    {d['path']:<40} {d['size_h']:<12}")

        lines.append("")
        leaks = data.get("leaks", [])
        if leaks:
            lines.append("  ⚠️  Fuites détectées :")
            for leak in leaks:
                lines.append(f"    → {leak['path']:<40} {leak['size_h']:<12} ({leak['type']})")
        else:
            lines.append("  ✅ Aucune fuite détectée")

        return "\n".join(lines)

    def _get_partitions(self) -> list[dict]:
        partitions = []
        for mp in self._list_mountpoints():
            try:
                usage = shutil.disk_usage(mp)
                partitions.append({
                    "mountpoint": mp,
                    "total":      usage.total,
                    "used":       usage.used,
                    "free":       usage.free,
                    "percent":    round((usage.used / usage.total) * 100, 1),
                    "total_h":    self._human(usage.total),
                    "used_h":     self._human(usage.used),
                    "free_h":     self._human(usage.free),
                })
            except OSError as e:
                logger.warning("Partition inaccessible %s : %s", mp, e)
        return partitions

    def _list_mountpoints(self) -> list[str]:
        mountpoints = []
        try:
            with open("/proc/mounts", "r") as f:
                for line in f:
                    parts = line.split()
                    if len(parts) >= 2:
                        mp = parts[1]
                        if mp not in self.exclude_dirs and not any(mp.startswith(ex) for ex in self.exclude_dirs):
                            mountpoints.append(mp)
        except FileNotFoundError:
            logger.error("/proc/mounts introuvable")
        return mountpoints

    def _get_top_directories(self, root: str, max_depth: int, top_n: int = 10) -> list[dict]:
        sizes = {}
        for dirpath, dirnames, _ in os.walk(root):
            depth = dirpath.replace(root, "").count(os.sep)
            if depth >= max_depth:
                dirnames.clear()
                continue
            if any(dirpath.startswith(ex) for ex in self.exclude_dirs):
                dirnames.clear()
                continue
            try:
                total = 0
                for entry in os.scandir(dirpath):
                    try:
                        if entry.is_file(follow_symlinks=False):
                            total += entry.stat().st_size
                    except OSError:
                        continue
                sizes[dirpath] = total
            except PermissionError:
                continue

        sorted_dirs = sorted(sizes.items(), key=lambda x: x[1], reverse=True)[:top_n]
        return [{"path": path, "size": size, "size_h": self._human(size)} for path, size in sorted_dirs]

    def _detect_leaks(self) -> list[dict]:
        leaks = []
        leak_targets = [
            ("/var/log",           "logs",   50 * 1024 * 1024),
            ("/var/cache/apt",     "cache",  100 * 1024 * 1024),
            ("/tmp",               "tmp",    200 * 1024 * 1024),
            ("/var/cache",         "cache",  200 * 1024 * 1024),
            ("/root/.cache",       "cache",  100 * 1024 * 1024),
            ("/home",              "home",   5 * 1024 * 1024 * 1024),
        ]
        for path, leak_type, threshold in leak_targets:
            size = self._get_dir_size(path)
            if size and size > threshold:
                leaks.append({
                    "path":   path,
                    "type":   leak_type,
                    "size":   size,
                    "size_h": self._human(size),
                })
        return leaks

    def _get_dir_size(self, path: str) -> int | None:
        try:
            result = subprocess.run(
                ["du", "-sb", path],
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode == 0:
                return int(result.stdout.strip().split()[0])
        except (subprocess.TimeoutExpired, Exception) as e:
            logger.warning("Erreur du sur %s : %s", path, e)
        return None

    @staticmethod
    def _human(size_bytes: int) -> str:
        for unit in ["B", "KB", "MB", "GB", "TB"]:
            if size_bytes < 1024:
                return f"{size_bytes:.1f} {unit}"
            size_bytes /= 1024
        return f"{size_bytes:.1f} PB"
