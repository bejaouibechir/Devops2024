import importlib
import time
from datetime import datetime
from trumpito_core.logger import get_logger
from trumpito_core.config import TrumpitoConfig
from trumpito_modules.base import TrumpitoModule

logger = get_logger("trumpito.module_loader")

MODULE_PACKAGE = "trumpito_modules"

AVAILABLE_MODULES = {
    "disk":     "disk",
    "services": "services",
    "network":  "network",
    "packages": "packages",
}


class ModuleLoader:

    def __init__(self, config: TrumpitoConfig):
        self.config = config
        self.enabled = config.get_modules_enabled()
        self.loaded: dict[str, TrumpitoModule] = {}
        self._discover()

    def _discover(self):
        for name, module_file in AVAILABLE_MODULES.items():
            if name not in self.enabled:
                logger.debug("Module ignoré (désactivé) : %s", name)
                continue
            try:
                mod = importlib.import_module(f"{MODULE_PACKAGE}.{module_file}")
                cls = getattr(mod, "Module")
                instance = cls()
                self.loaded[name] = instance
                logger.info("Module chargé : %s v%s", name, instance.version)
            except (ImportError, AttributeError) as e:
                logger.error("Échec chargement module '%s' : %s", name, e)

    def list_modules(self) -> list[dict]:
        results = []
        for name, instance in self.loaded.items():
            results.append({
                "name": instance.name,
                "description": instance.description,
                "version": instance.version,
                "requires_root": instance.requires_root,
                "enabled": True,
            })
        for name in AVAILABLE_MODULES:
            if name not in self.loaded and name not in self.enabled:
                results.append({
                    "name": name,
                    "description": "—",
                    "version": "—",
                    "requires_root": False,
                    "enabled": False,
                })
        return results

    def run_one(self, name: str) -> dict | None:
        if name not in self.loaded:
            logger.error("Module '%s' non trouvé ou non chargé", name)
            print(f"\n❌ Module '{name}' introuvable.\n")
            return None
        return self._execute(name, self.loaded[name])

    def run_all(self) -> list[dict]:
        results = []
        for name, instance in self.loaded.items():
            result = self._execute(name, instance)
            results.append(result)
        return results

    def _execute(self, name: str, module: TrumpitoModule) -> dict:
        logger.info("Exécution du module : %s", name)
        start = time.time()
        try:
            module.executed_at = datetime.now()
            data = module.run()
            duration = round(time.time() - start, 3)
            module.duration_sec = duration
            output = module.format_output(data)
            logger.info("Module %s terminé en %ss", name, duration)
            return {
                "name": name,
                "status": "ok",
                "duration_sec": duration,
                "errors": module.errors,
                "output": output,
                "data": data,
            }
        except Exception as e:
            duration = round(time.time() - start, 3)
            logger.error("Module %s échoué : %s", name, e)
            return {
                "name": name,
                "status": "error",
                "duration_sec": duration,
                "errors": [str(e)],
                "output": "",
                "data": {},
            }
