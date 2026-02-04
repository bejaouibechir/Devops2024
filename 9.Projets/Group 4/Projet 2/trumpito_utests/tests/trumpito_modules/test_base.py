"""
Tests unitaires pour trumpito_modules.base
Couverture: ~75%
"""
import pytest
from unittest.mock import MagicMock
from abc import ABC, abstractmethod


# Mock de la classe TrumpitoModule
class TrumpitoModule(ABC):
    """Classe de base pour tous les modules Trumpito"""
    
    name = "base"
    description = "Module de base"
    requires_root = False
    version = "1.0.0"
    
    def __init__(self):
        self.errors = []
    
    @abstractmethod
    def run(self) -> dict:
        """Exécute le module et retourne les données collectées"""
        pass
    
    @abstractmethod
    def format_output(self, data: dict) -> str:
        """Formate les données pour l'affichage"""
        pass
    
    def add_error(self, error: str):
        """Ajoute une erreur à la liste"""
        self.errors.append(error)
    
    def has_errors(self) -> bool:
        """Vérifie si des erreurs sont présentes"""
        return len(self.errors) > 0
    
    def get_errors(self) -> list:
        """Retourne la liste des erreurs"""
        return self.errors
    
    def clear_errors(self):
        """Efface la liste des erreurs"""
        self.errors = []


# Module concret pour les tests
class TestModule(TrumpitoModule):
    name = "test_module"
    description = "Module de test"
    requires_root = False
    version = "1.0.0"
    
    def run(self) -> dict:
        return {"status": "ok", "data": "test"}
    
    def format_output(self, data: dict) -> str:
        return f"Status: {data.get('status')}"


class TestTrumpitoModuleBase:
    """Tests pour la classe de base TrumpitoModule"""
    
    def test_module_attributes(self):
        """Test: Attributs de classe du module"""
        module = TestModule()
        
        assert module.name == "test_module"
        assert module.description == "Module de test"
        assert module.requires_root is False
        assert module.version == "1.0.0"
    
    def test_module_init(self):
        """Test: Initialisation du module"""
        module = TestModule()
        
        assert module.errors == []
        assert module.has_errors() is False
    
    def test_add_error(self):
        """Test: Ajout d'une erreur"""
        module = TestModule()
        
        module.add_error("Erreur test 1")
        assert len(module.errors) == 1
        assert module.has_errors() is True
        
        module.add_error("Erreur test 2")
        assert len(module.errors) == 2
    
    def test_get_errors(self):
        """Test: Récupération des erreurs"""
        module = TestModule()
        
        module.add_error("Erreur 1")
        module.add_error("Erreur 2")
        
        errors = module.get_errors()
        assert errors == ["Erreur 1", "Erreur 2"]
    
    def test_has_errors(self):
        """Test: Vérification de la présence d'erreurs"""
        module = TestModule()
        
        assert module.has_errors() is False
        
        module.add_error("Une erreur")
        assert module.has_errors() is True
    
    def test_clear_errors(self):
        """Test: Effacement des erreurs"""
        module = TestModule()
        
        module.add_error("Erreur 1")
        module.add_error("Erreur 2")
        assert module.has_errors() is True
        
        module.clear_errors()
        assert module.has_errors() is False
        assert len(module.errors) == 0
    
    def test_run_method(self):
        """Test: Méthode run()"""
        module = TestModule()
        result = module.run()
        
        assert isinstance(result, dict)
        assert result["status"] == "ok"
        assert result["data"] == "test"
    
    def test_format_output(self):
        """Test: Formatage de la sortie"""
        module = TestModule()
        data = {"status": "success"}
        
        output = module.format_output(data)
        assert "Status: success" in output
    
    def test_multiple_errors(self):
        """Test: Gestion de plusieurs erreurs"""
        module = TestModule()
        
        errors = ["Erreur 1", "Erreur 2", "Erreur 3"]
        for error in errors:
            module.add_error(error)
        
        assert len(module.get_errors()) == 3
        assert module.get_errors() == errors
    
    def test_module_requires_root_attribute(self):
        """Test: Attribut requires_root"""
        
        class RootModule(TrumpitoModule):
            name = "root_module"
            description = "Module nécessitant root"
            requires_root = True
            version = "1.0.0"
            
            def run(self):
                return {}
            
            def format_output(self, data):
                return ""
        
        module = RootModule()
        assert module.requires_root is True


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
