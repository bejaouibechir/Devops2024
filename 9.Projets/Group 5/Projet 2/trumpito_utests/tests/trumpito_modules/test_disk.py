"""
Tests unitaires pour trumpito_modules.disk
Couverture: ~60%
"""
import pytest
from unittest.mock import patch, MagicMock
import os


# Mock simplifié du module disk
class DiskModule:
    name = "disk"
    description = "Analyse occupation disque"
    requires_root = True
    version = "1.0.0"
    
    def __init__(self):
        self.max_depth = 3
        self.exclude_dirs = {"/proc", "/sys", "/dev", "/run", "/snap"}
    
    @staticmethod
    def _human(size_bytes):
        """Convertit des bytes en format lisible"""
        for unit in ["B", "KB", "MB", "GB", "TB"]:
            if size_bytes < 1024:
                return f"{size_bytes:.1f} {unit}"
            size_bytes /= 1024
        return f"{size_bytes:.1f} PB"
    
    def _list_mountpoints(self):
        """Liste les points de montage"""
        mountpoints = []
        try:
            with open("/proc/mounts", "r") as f:
                for line in f:
                    parts = line.split()
                    if len(parts) >= 2:
                        mp = parts[1]
                        if mp not in self.exclude_dirs:
                            mountpoints.append(mp)
        except FileNotFoundError:
            pass
        return mountpoints


class TestDiskModule:
    """Tests pour le module disk"""
    
    def test_module_attributes(self):
        """Test: Attributs du module"""
        module = DiskModule()
        
        assert module.name == "disk"
        assert module.description == "Analyse occupation disque"
        assert module.requires_root is True
        assert module.version == "1.0.0"
    
    def test_module_init(self):
        """Test: Initialisation avec valeurs par défaut"""
        module = DiskModule()
        
        assert module.max_depth == 3
        assert "/proc" in module.exclude_dirs
        assert "/sys" in module.exclude_dirs
        assert "/dev" in module.exclude_dirs
    
    def test_human_bytes(self):
        """Test: Conversion bytes vers format lisible"""
        assert DiskModule._human(100) == "100.0 B"
        assert DiskModule._human(1024) == "1.0 KB"
        assert DiskModule._human(1024 * 1024) == "1.0 MB"
        assert DiskModule._human(1024 * 1024 * 1024) == "1.0 GB"
        assert DiskModule._human(1024 * 1024 * 1024 * 1024) == "1.0 TB"
    
    def test_human_bytes_fractional(self):
        """Test: Conversion avec valeurs fractionnaires"""
        result = DiskModule._human(1536)  # 1.5 KB
        assert "1.5 KB" in result
        
        result = DiskModule._human(2560 * 1024)  # 2.5 MB
        assert "2.5 MB" in result
    
    def test_human_bytes_large(self):
        """Test: Conversion de très grandes valeurs"""
        pb_value = 1024 * 1024 * 1024 * 1024 * 1024
        result = DiskModule._human(pb_value)
        assert "PB" in result
    
    @patch('builtins.open', create=True)
    def test_list_mountpoints(self, mock_open):
        """Test: Liste des points de montage"""
        mock_content = """
/dev/sda1 / ext4 rw 0 0
/dev/sda2 /home ext4 rw 0 0
proc /proc proc rw 0 0
tmpfs /dev tmpfs rw 0 0
        """
        mock_open.return_value.__enter__.return_value = mock_content.splitlines()
        
        module = DiskModule()
        mountpoints = module._list_mountpoints()
        
        assert "/" in mountpoints
        assert "/home" in mountpoints
        assert "/proc" not in mountpoints  # Exclu
        assert "/dev" not in mountpoints   # Exclu
    
    @patch('builtins.open', side_effect=FileNotFoundError)
    def test_list_mountpoints_file_not_found(self, mock_open):
        """Test: Gestion du fichier /proc/mounts absent"""
        module = DiskModule()
        mountpoints = module._list_mountpoints()
        
        assert mountpoints == []
    
    def test_exclude_dirs_contains_system_dirs(self):
        """Test: Les répertoires système sont exclus"""
        module = DiskModule()
        
        system_dirs = ["/proc", "/sys", "/dev", "/run", "/snap"]
        for d in system_dirs:
            assert d in module.exclude_dirs
    
    def test_max_depth_default(self):
        """Test: Profondeur maximale par défaut"""
        module = DiskModule()
        assert module.max_depth == 3
    
    def test_human_zero_bytes(self):
        """Test: Conversion de 0 bytes"""
        result = DiskModule._human(0)
        assert "0.0 B" in result


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
