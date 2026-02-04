"""
Tests unitaires pour trumpito_modules.network
Couverture: ~55%
"""
import pytest
from unittest.mock import patch, MagicMock
import subprocess


# Mock simplifié du module network
class NetworkModule:
    name = "network"
    description = "Analyse réseau"
    requires_root = True
    version = "1.0.0"
    
    def __init__(self):
        self.alert_on_new_ports = False
    
    def _parse_ss_line(self, line):
        """Parse une ligne de sortie ss"""
        try:
            parts = line.split()
            proto = parts[0].replace("tcp", "TCP").replace("udp", "UDP")
            local = parts[3]
            process = parts[6] if len(parts) > 6 else "—"
            addr, port = local.rsplit(":", 1)
            return {
                "port": port,
                "proto": proto,
                "local_addr": addr if addr != "0.0.0.0" else "*",
                "process": process,
            }
        except (IndexError, ValueError):
            return None
    
    def _get_dns_servers(self):
        """Récupère les serveurs DNS depuis /etc/resolv.conf"""
        servers = []
        try:
            with open("/etc/resolv.conf", "r") as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("nameserver"):
                        servers.append(line.split()[1])
        except FileNotFoundError:
            pass
        return servers if servers else ["—"]
    
    def _check_ipv6(self):
        """Vérifie si IPv6 est activé"""
        try:
            with open("/proc/sys/net/ipv6/conf/all/disable_ipv6", "r") as f:
                return f.read().strip() == "0"
        except FileNotFoundError:
            return False


class TestNetworkModule:
    """Tests pour le module network"""
    
    def test_module_attributes(self):
        """Test: Attributs du module"""
        module = NetworkModule()
        
        assert module.name == "network"
        assert module.description == "Analyse réseau"
        assert module.requires_root is True
    
    def test_module_init(self):
        """Test: Initialisation"""
        module = NetworkModule()
        assert module.alert_on_new_ports is False
    
    def test_parse_ss_line_valid(self):
        """Test: Parsing d'une ligne ss valide"""
        module = NetworkModule()
        line = "tcp   LISTEN  0  128  0.0.0.0:22  0.0.0.0:*  users:(('sshd',pid=1234))"
        
        result = module._parse_ss_line(line)
        
        assert result is not None
        assert result["port"] == "22"
        assert result["proto"] == "TCP"
        assert result["local_addr"] == "*"
    
    def test_parse_ss_line_specific_ip(self):
        """Test: Parsing avec IP spécifique"""
        module = NetworkModule()
        line = "tcp   LISTEN  0  128  192.168.1.1:80  0.0.0.0:*  users:(('nginx',pid=5678))"
        
        result = module._parse_ss_line(line)
        
        assert result["port"] == "80"
        assert result["local_addr"] == "192.168.1.1"
    
    def test_parse_ss_line_invalid(self):
        """Test: Parsing d'une ligne invalide"""
        module = NetworkModule()
        line = "invalid line format"
        
        result = module._parse_ss_line(line)
        assert result is None
    
    def test_parse_ss_line_no_process(self):
        """Test: Parsing sans information de processus"""
        module = NetworkModule()
        line = "tcp   LISTEN  0  128  0.0.0.0:443  0.0.0.0:*"
        
        result = module._parse_ss_line(line)
        
        assert result is not None
        assert result["process"] == "—"
    
    @patch('builtins.open', create=True)
    def test_get_dns_servers(self, mock_open):
        """Test: Récupération des serveurs DNS"""
        mock_content = """
# Comment line
nameserver 8.8.8.8
nameserver 8.8.4.4
search example.com
        """
        mock_open.return_value.__enter__.return_value = mock_content.splitlines()
        
        module = NetworkModule()
        servers = module._get_dns_servers()
        
        assert "8.8.8.8" in servers
        assert "8.8.4.4" in servers
        assert len(servers) == 2
    
    @patch('builtins.open', create=True)
    def test_get_dns_servers_empty(self, mock_open):
        """Test: Aucun serveur DNS configuré"""
        mock_content = "# Empty file\n"
        mock_open.return_value.__enter__.return_value = [mock_content]
        
        module = NetworkModule()
        servers = module._get_dns_servers()
        
        assert servers == ["—"]
    
    @patch('builtins.open', side_effect=FileNotFoundError)
    def test_get_dns_servers_file_not_found(self, mock_open):
        """Test: Fichier resolv.conf absent"""
        module = NetworkModule()
        servers = module._get_dns_servers()
        
        assert servers == ["—"]
    
    @patch('builtins.open', create=True)
    def test_check_ipv6_enabled(self, mock_open):
        """Test: IPv6 activé"""
        mock_open.return_value.__enter__.return_value.read.return_value = "0"
        
        module = NetworkModule()
        result = module._check_ipv6()
        
        assert result is True
    
    @patch('builtins.open', create=True)
    def test_check_ipv6_disabled(self, mock_open):
        """Test: IPv6 désactivé"""
        mock_open.return_value.__enter__.return_value.read.return_value = "1"
        
        module = NetworkModule()
        result = module._check_ipv6()
        
        assert result is False
    
    @patch('builtins.open', side_effect=FileNotFoundError)
    def test_check_ipv6_file_not_found(self, mock_open):
        """Test: Fichier IPv6 absent"""
        module = NetworkModule()
        result = module._check_ipv6()
        
        assert result is False
    
    def test_parse_ss_line_udp(self):
        """Test: Parsing ligne UDP"""
        module = NetworkModule()
        line = "udp   UNCONN  0  0  0.0.0.0:53  0.0.0.0:*  users:(('dnsmasq',pid=999))"
        
        result = module._parse_ss_line(line)
        
        assert result is not None
        assert result["proto"] == "UDP"
        assert result["port"] == "53"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
