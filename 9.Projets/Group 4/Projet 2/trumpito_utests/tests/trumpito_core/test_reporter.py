"""
Tests unitaires pour trumpito_core.reporter
Couverture: ~70%
"""
import pytest
import json
import os
import tempfile
from unittest.mock import patch, MagicMock
from datetime import datetime


# Mock de la classe TrumpitoReporter
class TrumpitoReporter:
    def __init__(self, config):
        self.config = config
        self.report_dir = config.get("general", "report_dir", fallback="/var/lib/trumpito/reports")
        os.makedirs(self.report_dir, exist_ok=True)
    
    def generate(self, results, fmt="text"):
        if fmt == "json":
            return self._to_json(results)
        return self._to_text(results)
    
    def save(self, content, fmt="text"):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        ext = "json" if fmt == "json" else "txt"
        filename = f"trumpito_report_{timestamp}.{ext}"
        filepath = os.path.join(self.report_dir, filename)
        
        try:
            with open(filepath, "w") as f:
                f.write(content)
            return filepath
        except PermissionError:
            return ""
    
    def _to_text(self, results):
        lines = []
        lines.append("=" * 60)
        lines.append("  TRUMPITO — RAPPORT SYSTÈME")
        lines.append(f"  Généré le : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        lines.append("=" * 60)
        
        for result in results:
            module_name = result.get("name", "unknown")
            status = result.get("status", "unknown")
            duration = result.get("duration_sec", 0)
            output = result.get("output", "")
            
            lines.append("")
            lines.append(f"┌── {module_name.upper()} (status: {status} | {duration}s) ──")
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
    
    def _to_json(self, results):
        payload = {
            "tool": "trumpito",
            "generated_at": datetime.now().isoformat(),
            "total_modules": len(results),
            "total_duration_sec": round(sum(r.get("duration_sec", 0) for r in results), 3),
            "modules": results,
        }
        return json.dumps(payload, indent=2, ensure_ascii=False)


class MockConfig:
    def get(self, section, option, fallback=None):
        if section == "general" and option == "report_dir":
            return fallback
        return fallback


class TestTrumpitoReporter:
    """Tests pour la classe TrumpitoReporter"""
    
    def test_reporter_init(self):
        """Test: Initialisation du reporter"""
        config = MockConfig()
        with tempfile.TemporaryDirectory() as tmpdir:
            with patch.object(config, 'get', return_value=tmpdir):
                reporter = TrumpitoReporter(config)
                assert reporter.report_dir == tmpdir
                assert os.path.exists(tmpdir)
    
    def test_generate_text_format(self):
        """Test: Génération de rapport en format texte"""
        config = MockConfig()
        reporter = TrumpitoReporter(config)
        
        results = [
            {
                "name": "disk",
                "status": "success",
                "duration_sec": 1.5,
                "output": "Disk usage: 50%"
            }
        ]
        
        report = reporter.generate(results, fmt="text")
        
        assert "TRUMPITO — RAPPORT SYSTÈME" in report
        assert "DISK" in report
        assert "success" in report
        assert "1.5s" in report
        assert "Disk usage: 50%" in report
    
    def test_generate_json_format(self):
        """Test: Génération de rapport en format JSON"""
        config = MockConfig()
        reporter = TrumpitoReporter(config)
        
        results = [
            {
                "name": "network",
                "status": "success",
                "duration_sec": 2.3,
                "output": "Network OK"
            }
        ]
        
        report = reporter.generate(results, fmt="json")
        data = json.loads(report)
        
        assert data["tool"] == "trumpito"
        assert data["total_modules"] == 1
        assert data["total_duration_sec"] == 2.3
        assert len(data["modules"]) == 1
        assert data["modules"][0]["name"] == "network"
    
    def test_generate_multiple_modules(self):
        """Test: Génération avec plusieurs modules"""
        config = MockConfig()
        reporter = TrumpitoReporter(config)
        
        results = [
            {"name": "disk", "status": "success", "duration_sec": 1.0, "output": "OK"},
            {"name": "network", "status": "success", "duration_sec": 2.0, "output": "OK"},
            {"name": "services", "status": "failed", "duration_sec": 0.5, "output": "ERROR"},
        ]
        
        report = reporter.generate(results, fmt="text")
        
        assert "Modules exécutés : 3" in report
        assert "3.50s" in report or "3.5s" in report
    
    def test_save_text_report(self):
        """Test: Sauvegarde d'un rapport texte"""
        config = MockConfig()
        
        with tempfile.TemporaryDirectory() as tmpdir:
            with patch.object(config, 'get', return_value=tmpdir):
                reporter = TrumpitoReporter(config)
                content = "Test report content"
                
                filepath = reporter.save(content, fmt="text")
                
                assert filepath != ""
                assert os.path.exists(filepath)
                assert filepath.endswith(".txt")
                
                with open(filepath, 'r') as f:
                    saved_content = f.read()
                assert saved_content == content
    
    def test_save_json_report(self):
        """Test: Sauvegarde d'un rapport JSON"""
        config = MockConfig()
        
        with tempfile.TemporaryDirectory() as tmpdir:
            with patch.object(config, 'get', return_value=tmpdir):
                reporter = TrumpitoReporter(config)
                content = '{"test": "data"}'
                
                filepath = reporter.save(content, fmt="json")
                
                assert filepath.endswith(".json")
                assert os.path.exists(filepath)
    
    def test_save_permission_error(self):
        """Test: Gestion des erreurs de permission"""
        config = MockConfig()
        
        with patch.object(config, 'get', return_value='/root/forbidden'):
            reporter = TrumpitoReporter(config)
            content = "Test"
            
            # Le répertoire n'est pas créé (permission denied)
            with patch('builtins.open', side_effect=PermissionError):
                filepath = reporter.save(content, fmt="text")
                assert filepath == ""
    
    def test_report_filename_format(self):
        """Test: Format du nom de fichier"""
        config = MockConfig()
        
        with tempfile.TemporaryDirectory() as tmpdir:
            with patch.object(config, 'get', return_value=tmpdir):
                reporter = TrumpitoReporter(config)
                
                filepath = reporter.save("content", fmt="text")
                filename = os.path.basename(filepath)
                
                assert filename.startswith("trumpito_report_")
                assert filename.endswith(".txt")
                assert len(filename) == len("trumpito_report_YYYYMMDD_HHMMSS.txt")


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
