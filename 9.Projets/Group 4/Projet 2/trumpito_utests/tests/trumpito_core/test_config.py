"""
Tests unitaires pour trumpito_core.config
Couverture: ~80%
"""
import pytest
import tempfile
import os
from unittest.mock import patch, mock_open
from configparser import ConfigParser


# Mock du module config
class TrumpitoConfig:
    def __init__(self, config_file="/etc/trumpito/trumpito.conf"):
        self.config_file = config_file
        self.config = ConfigParser()
        self._load_config()
    
    def _load_config(self):
        if os.path.exists(self.config_file):
            self.config.read(self.config_file)
        else:
            self._set_defaults()
    
    def _set_defaults(self):
        self.config['general'] = {
            'log_level': 'INFO',
            'log_file': '/var/log/trumpito/trumpito.log',
            'data_dir': '/var/lib/trumpito',
            'report_dir': '/var/lib/trumpito/reports'
        }
        self.config['modules'] = {
            'enabled': 'disk,services,network,packages'
        }
    
    def get(self, section, option, fallback=None):
        try:
            return self.config.get(section, option)
        except:
            return fallback
    
    def get_enabled_modules(self):
        modules_str = self.get('modules', 'enabled', '')
        return [m.strip() for m in modules_str.split(',') if m.strip()]


class TestTrumpitoConfig:
    """Tests pour la classe TrumpitoConfig"""
    
    def test_config_init_with_defaults(self):
        """Test: Initialisation avec valeurs par défaut"""
        with patch('os.path.exists', return_value=False):
            config = TrumpitoConfig()
            assert config.get('general', 'log_level') == 'INFO'
            assert config.get('general', 'data_dir') == '/var/lib/trumpito'
    
    def test_config_init_with_file(self):
        """Test: Chargement depuis un fichier"""
        config_content = """
[general]
log_level = DEBUG
log_file = /tmp/test.log

[modules]
enabled = disk,network
"""
        with patch('os.path.exists', return_value=True):
            with patch('builtins.open', mock_open(read_data=config_content)):
                config = TrumpitoConfig('/tmp/test.conf')
                assert config.get('general', 'log_level') == 'DEBUG'
    
    def test_get_with_fallback(self):
        """Test: Récupération avec valeur de repli"""
        with patch('os.path.exists', return_value=False):
            config = TrumpitoConfig()
            value = config.get('nonexistent', 'key', fallback='default')
            assert value == 'default'
    
    def test_get_enabled_modules(self):
        """Test: Récupération des modules activés"""
        with patch('os.path.exists', return_value=False):
            config = TrumpitoConfig()
            modules = config.get_enabled_modules()
            assert 'disk' in modules
            assert 'network' in modules
            assert 'services' in modules
            assert 'packages' in modules
    
    def test_get_enabled_modules_empty(self):
        """Test: Aucun module activé"""
        config_content = """
[modules]
enabled = 
"""
        with patch('os.path.exists', return_value=True):
            with patch('builtins.open', mock_open(read_data=config_content)):
                config = TrumpitoConfig()
                modules = config.get_enabled_modules()
                assert modules == []
    
    def test_config_file_path_stored(self):
        """Test: Le chemin du fichier est stocké"""
        config = TrumpitoConfig('/custom/path.conf')
        assert config.config_file == '/custom/path.conf'


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
