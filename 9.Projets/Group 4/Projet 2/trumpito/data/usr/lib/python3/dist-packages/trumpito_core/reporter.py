import os
import json
from datetime import datetime
from trumpito_core.logger import get_logger
from trumpito_core.config import TrumpitoConfig

logger = get_logger("trumpito.reporter")


class TrumpitoReporter:

    def __init__(self, config: TrumpitoConfig):
        self.config = config
        self.report_dir = config.get("general", "report_dir", fallback="/var/lib/trumpito/reports")
        os.makedirs(self.report_dir, exist_ok=True)

    def generate(self, results: list[dict], fmt: str = "text") -> str:
        if fmt == "json":
            return self._to_json(results)
        return self._to_text(results)

    def save(self, content: str, fmt: str = "text") -> str:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        ext = "json" if fmt == "json" else "txt"
        filename = f"trumpito_report_{timestamp}.{ext}"
        filepath = os.path.join(self.report_dir, filename)

        try:
            with open(filepath, "w") as f:
                f.write(content)
            logger.info("Rapport sauvegardé : %s", filepath)
            return filepath
        except PermissionError:
            logger.error("Impossible d'écrire dans %s", self.report_dir)
            return ""

    def _to_text(self, results: list[dict]) -> str:
        lines = []
        lines.append("=" * 60)
        lines.append("  TRUMPITO — RAPPORT SYSTÈME")
        lines.append(f"  Généré le : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        lines.append("=" * 60)

        for result in results:
            module_name = result.get("name", "unknown")
            status = result.get("status", "unknown")
            duration = result.get("duration_sec", 0)
            errors = result.get("errors", [])
            output = result.get("output", "")

            lines.append("")
            lines.append(f"┌── {module_name.upper()} (status: {status} | {duration}s) ──")
            lines.append("│")

            if errors:
                for err in errors:
                    lines.append(f"│  ⚠️  {err}")
                lines.append("│")

            if output:
                for line in output.splitlines():
                    lines.append(f"│  {line}")

            lines.append("└" + "─" * 50)

        lines.append("")
        lines.append("=" * 60)
        lines.append(f"  Modules exécutés : {len(results)}")
        lines.append(f"  Durée totale     : {sum(r.get('duration_sec', 0) for r in results):.2f}s")
        lines.append("=" * 60)

        return "\n".join(lines)

    def _to_json(self, results: list[dict]) -> str:
        payload = {
            "tool": "trumpito",
            "generated_at": datetime.now().isoformat(),
            "total_modules": len(results),
            "total_duration_sec": round(sum(r.get("duration_sec", 0) for r in results), 3),
            "modules": results,
        }
        return json.dumps(payload, indent=2, ensure_ascii=False)
