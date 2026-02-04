from abc import ABC, abstractmethod
from datetime import datetime


class TrumpitoModule(ABC):

    name: str = ""
    description: str = ""
    requires_root: bool = False
    version: str = "1.0.0"

    def __init__(self):
        self.executed_at: datetime | None = None
        self.duration_sec: float = 0.0
        self.errors: list[str] = []

    @abstractmethod
    def run(self) -> dict:
        pass

    @abstractmethod
    def format_output(self, data: dict) -> str:
        pass

    def get_metadata(self) -> dict:
        return {
            "name": self.name,
            "description": self.description,
            "requires_root": self.requires_root,
            "version": self.version,
            "executed_at": self.executed_at.isoformat() if self.executed_at else None,
            "duration_sec": round(self.duration_sec, 3),
            "errors": self.errors,
        }

    def add_error(self, message: str):
        self.errors.append(message)

    def __repr__(self) -> str:
        return f"<TrumpitoModule name={self.name} v{self.version}>"
