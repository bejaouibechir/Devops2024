import logging
import os
import sys
from logging.handlers import RotatingFileHandler

DEFAULT_LOG_DIR  = "/var/log/trumpito"
DEFAULT_LOG_FILE = os.path.join(DEFAULT_LOG_DIR, "trumpito.log")

MAX_LOG_SIZE_BYTES = 5 * 1024 * 1024
BACKUP_COUNT       = 3

LOG_FORMAT = "%(asctime)s [%(levelname)-8s] %(name)-20s %(message)s"
DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

VALID_LEVELS = {"DEBUG", "INFO", "WARNING", "ERROR"}


def get_logger(
    name: str = "trumpito",
    level: str = "INFO",
    log_file: str | None = None,
    dev_mode: bool = False,
) -> logging.Logger:

    level = level.upper()
    if level not in VALID_LEVELS:
        level = "INFO"

    logger = logging.getLogger(name)
    if logger.handlers:
        return logger

    logger.setLevel(getattr(logging, level))

    formatter = logging.Formatter(LOG_FORMAT, datefmt=DATE_FORMAT)

    target_file = log_file or DEFAULT_LOG_FILE

    try:
        os.makedirs(os.path.dirname(target_file), exist_ok=True)
        file_handler = RotatingFileHandler(
            target_file,
            maxBytes=MAX_LOG_SIZE_BYTES,
            backupCount=BACKUP_COUNT,
        )
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)

    except PermissionError:
        fallback = os.path.join(os.getcwd(), "trumpito.log")
        file_handler = RotatingFileHandler(
            fallback,
            maxBytes=MAX_LOG_SIZE_BYTES,
            backupCount=BACKUP_COUNT,
        )
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
        logger.warning("Impossible d'écrire dans %s → fallback vers %s", target_file, fallback)

    if dev_mode:
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setFormatter(formatter)
        console_handler.setLevel(getattr(logging, level))
        logger.addHandler(console_handler)

    return logger
