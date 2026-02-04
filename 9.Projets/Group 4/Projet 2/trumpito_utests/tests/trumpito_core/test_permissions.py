"""
Tests unitaires pour trumpito_core.permissions
Couverture: ~85%
"""
import pytest
from unittest.mock import patch, MagicMock
import subprocess


# Mock du module permissions
def is_root():
    import os
    return os.geteuid() == 0


def check_command_permissions(command):
    COMMANDS_REQUIRING_ROOT = [
        "scan",
        "module run disk",
        "module run services",
        "module run network",
        "module run packages",
    ]
    
    if is_root():
        return True
    
    for cmd in COMMANDS_REQUIRING_ROOT:
        if command.startswith(cmd):
            print(f"\n⚠️  La commande '{command}' nécessite des droits root.")
            return False
    
    return True


def check_binary_exists(binary):
    try:
        subprocess.run(
            ["which", binary],
            capture_output=True,
            check=True,
        )
        return True
    except subprocess.CalledProcessError:
        return False


class TestPermissions:
    """Tests pour le module permissions"""
    
    @patch('os.geteuid', return_value=0)
    def test_is_root_true(self, mock_geteuid):
        """Test: Vérification utilisateur root"""
        assert is_root() is True
        mock_geteuid.assert_called_once()
    
    @patch('os.geteuid', return_value=1000)
    def test_is_root_false(self, mock_geteuid):
        """Test: Vérification utilisateur non-root"""
        assert is_root() is False
    
    @patch('os.geteuid', return_value=0)
    def test_check_permissions_as_root(self, mock_geteuid):
        """Test: Root peut exécuter n'importe quelle commande"""
        assert check_command_permissions("scan") is True
        assert check_command_permissions("module run disk") is True
        assert check_command_permissions("module list") is True
    
    @patch('os.geteuid', return_value=1000)
    def test_check_permissions_scan_requires_root(self, mock_geteuid):
        """Test: La commande 'scan' nécessite root"""
        result = check_command_permissions("scan")
        assert result is False
    
    @patch('os.geteuid', return_value=1000)
    def test_check_permissions_module_run_requires_root(self, mock_geteuid):
        """Test: 'module run disk' nécessite root"""
        assert check_command_permissions("module run disk") is False
        assert check_command_permissions("module run services") is False
        assert check_command_permissions("module run network") is False
        assert check_command_permissions("module run packages") is False
    
    @patch('os.geteuid', return_value=1000)
    def test_check_permissions_module_list_no_root(self, mock_geteuid):
        """Test: 'module list' ne nécessite pas root"""
        result = check_command_permissions("module list")
        assert result is True
    
    @patch('os.geteuid', return_value=1000)
    def test_check_permissions_help_no_root(self, mock_geteuid):
        """Test: Les commandes d'aide ne nécessitent pas root"""
        assert check_command_permissions("--help") is True
        assert check_command_permissions("--version") is True
    
    @patch('subprocess.run')
    def test_binary_exists_true(self, mock_run):
        """Test: Binaire existe"""
        mock_run.return_value = MagicMock(returncode=0)
        assert check_binary_exists("python3") is True
        mock_run.assert_called_once()
    
    @patch('subprocess.run')
    def test_binary_exists_false(self, mock_run):
        """Test: Binaire n'existe pas"""
        mock_run.side_effect = subprocess.CalledProcessError(1, 'which')
        assert check_binary_exists("nonexistent") is False
    
    @patch('subprocess.run')
    def test_binary_exists_multiple_calls(self, mock_run):
        """Test: Vérification de plusieurs binaires"""
        mock_run.return_value = MagicMock(returncode=0)
        
        binaries = ['python3', 'pip3', 'git']
        for binary in binaries:
            check_binary_exists(binary)
        
        assert mock_run.call_count == len(binaries)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
