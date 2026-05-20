import os
import glob
import configparser
from trumpito_core.logger import get_logger

DEFAULT_CONF_FILE  = "/etc/trumpito/trumpito.conf"
DEFAULT_CONF_D     = "/etc/trumpito/conf.d"

DEFAULTS = {
    "general": {
        "log_level":  "INFO",
        "log_file":   "/var/log/trumpito/trumpito.log",
        "data_dir":   "/var/lib/trumpito",
        "report_dir": "/var/lib/trumpito/reports",
    },
    "modules": {
        "enabled": "disk,services,network,packages",
    },
    "disk": {
        "max_depth":    "3",
        "exclude_dirs": "/proc,/sys,/dev,/run",
    },
    "network": {
        "alert_on_new_ports": "false",
    },
    "services": {
        "exclude_services": "systemd-*",
    },
    "packages": {
        "history_days": "30",
    },
}

ENV_MAPPING = {
    "TRUMPITO_LOG_LEVEL":          ("general",  "log_level"),
    "TRUMPITO_LOG_FILE":           ("general",  "log_file"),
    "TRUMPITO_DATA_DIR":           ("general",  "data_dir"),
    "TRUMPITO_MODULES_ENABLED":    ("modules",  "enabled"),
    "TRUMPITO_DISK_MAX_DEPTH":     ("disk",     "max_depth"),
    "TRUMPITO_NETWORK_ALERT":      ("network",  "alert_on_new_ports"),
    "TRUMPITO_PACKAGES_HISTORY":   ("packages", "history_days"),
}


class TrumpitoConfig:

    def __init__(
        self,
        conf_file: str = DEFAULT_CONF_FILE,
        conf_d: str = DEFAULT_CONF_D,
    ):
        self.logger = get_logger("trumpito.config")
        self._parser = configparser.ConfigParser()
        self._parser.read_dict(DEFAULTS)
        self.logger.debug("Valeurs par défaut chargées")
        self._load_main_config(conf_file)
        self._load_conf_d(conf_d)
        self._load_env_overrides()

    def _load_main_config(self, conf_file: str):
        if os.path.isfile(conf_file):
            self._parser.read(conf_file)
            self.logger.info("Config principale chargée : %s", conf_file)
        else:
            self.logger.warning("Fichier config introuvable : %s → valeurs par défaut utilisées", conf_file)

    def _load_conf_d(self, conf_d: str):
        if not os.path.isdir(conf_d):
            self.logger.debug("Répertoire conf.d introuvable : %s", conf_d)
            return
        files = sorted(glob.glob(os.path.join(conf_d, "*.conf")))
        for f in files:
            self._parser.read(f)
            self.logger.info("Config conf.d chargée : %s", f)

    def _load_env_overrides(self):
        for env_var, (section, key) in ENV_MAPPING.items():
            value = os.environ.get(env_var)
            if value is not None:
                if not self._parser.has_section(section):
                    self._parser.add_section(section)
                self._parser.set(section, key, value)
                self.logger.info("Env override : %s=%s", env_var, value)

    def get(self, section: str, key: str, fallback: str = "") -> str:
        return self._parser.get(section, key, fallback=fallback)

    def get_int(self, section: str, key: str, fallback: int = 0) -> int:
        return self._parser.getint(section, key, fallback=fallback)

    def get_bool(self, section: str, key: str, fallback: bool = False) -> bool:
        return self._parser.getboolean(section, key, fallback=fallback)

    def get_list(self, section: str, key: str, fallback: list | None = None) -> list[str]:
        raw = self._parser.get(section, key, fallback="")
        if not raw:
            return fallback or []
        return [item.strip() for item in raw.split(",") if item.strip()]

    def get_modules_enabled(self) -> list[str]:
        return self.get_list("modules", "enabled")

    def dump(self) -> dict:
        return {section: dict(self._parser[section]) for section in self._parser.sections()}
