import subprocess
import socket
import json
import time
from trumpito_core.logger import get_logger
from trumpito_modules.base import TrumpitoModule

logger = get_logger("trumpito.network")


class Module(TrumpitoModule):

    name = "network"
    description = "Ports ouverts, connexions et vérifications réseau"
    requires_root = True
    version = "1.0.0"

    def __init__(self):
        super().__init__()
        self.alert_on_new_ports = False

    def run(self) -> dict:
        data = {
            "ports_open":    self._get_open_ports(),
            "connections":   self._get_active_connections(),
            "dns":           self._check_dns(),
            "routes":        self._get_routes(),
            "interfaces":    self._get_interfaces(),
            "ipv6_enabled":  self._check_ipv6(),
            "mtu":           self._get_mtu(),
        }
        return data

    def format_output(self, data: dict) -> str:
        lines = []

        lines.append("  🖥️  Interfaces réseau :")
        lines.append(f"    {'Interface':<12} {'Adresse':<20} {'MAC':<20} {'Statut'}")
        lines.append(f"    {'─'*12} {'─'*20} {'─'*20} {'─'*10}")
        for iface in data.get("interfaces", []):
            lines.append(
                f"    {iface['name']:<12} "
                f"{iface['address']:<20} "
                f"{iface['mac']:<20} "
                f"{iface['status']}"
            )
        lines.append("")

        lines.append("  🔓 Ports ouverts :")
        lines.append(f"    {'Port':<8} {'Protocole':<10} {'Processus':<25} {'Adresse locale'}")
        lines.append(f"    {'─'*8} {'─'*10} {'─'*25} {'─'*20}")
        for port in data.get("ports_open", []):
            lines.append(
                f"    {port['port']:<8} "
                f"{port['proto']:<10} "
                f"{port['process']:<25} "
                f"{port['local_addr']}"
            )
        lines.append("")

        lines.append("  🔄 Connexions actives :")
        lines.append(f"    {'Locale':<25} {'Distante':<25} {'État':<15} {'Protocole'}")
        lines.append(f"    {'─'*25} {'─'*25} {'─'*15} {'─'*10}")
        for conn in data.get("connections", []):
            lines.append(
                f"    {conn['local']:<25} "
                f"{conn['remote']:<25} "
                f"{conn['state']:<15} "
                f"{conn['proto']}"
            )
        lines.append("")

        lines.append("  🛣️  Table de routage :")
        lines.append(f"    {'Destination':<20} {'Passerelle':<20} {'Interface':<12} {'Métrique'}")
        lines.append(f"    {'─'*20} {'─'*20} {'─'*12} {'─'*8}")
        for route in data.get("routes", []):
            lines.append(
                f"    {route['dest']:<20} "
                f"{route['gateway']:<20} "
                f"{route['iface']:<12} "
                f"{route['metric']}"
            )
        lines.append("")

        dns = data.get("dns", {})
        lines.append("  🌐 DNS :")
        lines.append(f"    Serveurs    : {', '.join(dns.get('servers', []))}")
        lines.append(f"    Résolution  : {dns.get('resolution_test', '—')}")
        lines.append(f"    Latence     : {dns.get('latency_ms', '—')} ms")
        lines.append("")

        lines.append(f"  📦 MTU            : {data.get('mtu', '—')}")
        lines.append(f"  📦 IPv6 activé    : {'✅ Oui' if data.get('ipv6_enabled') else '❌ Non'}")

        return "\n".join(lines)

    def _get_open_ports(self) -> list[dict]:
        ports = []
        try:
            result = subprocess.run(
                ["ss", "-tlnp"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode != 0:
                return []
            for line in result.stdout.strip().splitlines()[1:]:
                parsed = self._parse_ss_line(line)
                if parsed:
                    ports.append(parsed)
        except Exception as e:
            logger.error("Erreur ss -tlnp : %s", e)
        return ports

    def _parse_ss_line(self, line: str) -> dict | None:
        try:
            parts = line.split()
            proto = parts[0].replace("tcp", "TCP").replace("udp", "UDP")
            local = parts[3]
            process = parts[6] if len(parts) > 6 else "—"
            addr, port = local.rsplit(":", 1)
            return {
                "port":       port,
                "proto":      proto,
                "local_addr": addr if addr != "0.0.0.0" else "*",
                "process":    process,
            }
        except (IndexError, ValueError) as e:
            logger.debug("Erreur parsing ligne ss : %s", e)
            return None

    def _get_active_connections(self) -> list[dict]:
        connections = []
        try:
            result = subprocess.run(
                ["ss", "-tnp"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode != 0:
                return []
            for line in result.stdout.strip().splitlines()[1:]:
                parsed = self._parse_connection_line(line)
                if parsed:
                    connections.append(parsed)
        except Exception as e:
            logger.error("Erreur ss -tnp : %s", e)
        return connections

    def _parse_connection_line(self, line: str) -> dict | None:
        try:
            parts = line.split()
            # Format ss -tnp : State Recv-Q Send-Q Local:Port Remote:Port [Process]
            if len(parts) < 5:
                return None
            state  = parts[0]
            local  = parts[3]
            remote = parts[4]
            process = parts[5] if len(parts) > 5 else "—"
            return {
                "local":   local,
                "remote":  remote,
                "state":   state,
                "proto":   "tcp",
                "process": process,
            }
        except (IndexError, ValueError) as e:
            logger.debug("Erreur parsing connexion : %s", e)
            return None

    def _check_dns(self) -> dict:
        dns = {
            "servers":          self._get_dns_servers(),
            "resolution_test":  "—",
            "latency_ms":       "—",
        }
        try:
            target = "google.com"
            start = time.time()
            socket.getaddrinfo(target, None)
            latency = round((time.time() - start) * 1000, 2)
            dns["resolution_test"] = f"{target} → OK"
            dns["latency_ms"] = latency
        except socket.gaierror:
            dns["resolution_test"] = "ÉCHEC"
        except Exception as e:
            logger.warning("Erreur test DNS : %s", e)
        return dns

    def _get_dns_servers(self) -> list[str]:
        servers = []
        try:
            with open("/etc/resolv.conf", "r") as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("nameserver"):
                        servers.append(line.split()[1])
        except FileNotFoundError:
            logger.warning("/etc/resolv.conf introuvable")
        return servers if servers else ["—"]

    def _get_routes(self) -> list[dict]:
        routes = []
        try:
            result = subprocess.run(
                ["ip", "route", "show"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode != 0:
                return []
            for line in result.stdout.strip().splitlines():
                parsed = self._parse_route_line(line)
                if parsed:
                    routes.append(parsed)
        except Exception as e:
            logger.error("Erreur ip route : %s", e)
        return routes

    def _parse_route_line(self, line: str) -> dict | None:
        try:
            route = {
                "dest":    "—",
                "gateway": "—",
                "iface":   "—",
                "metric":  "—",
            }
            parts = line.split()
            route["dest"] = parts[0]
            if "via" in parts:
                route["gateway"] = parts[parts.index("via") + 1]
            if "dev" in parts:
                route["iface"] = parts[parts.index("dev") + 1]
            if "metric" in parts:
                route["metric"] = parts[parts.index("metric") + 1]
            return route
        except (IndexError, ValueError) as e:
            logger.debug("Erreur parsing route : %s", e)
            return None

    def _get_interfaces(self) -> list[dict]:
        interfaces = []
        try:
            result = subprocess.run(
                ["ip", "addr", "show"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode != 0:
                return []

            current = None
            for line in result.stdout.splitlines():
                # Ligne de début : "2: ens5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ..."
                if line and not line[0].isspace():
                    parts = line.split()
                    # parts[0] = "2:" , parts[1] = "ens5:"
                    name = parts[1].rstrip(":")
                    # Extraire statut depuis les flags entre < >
                    status = "DOWN"
                    if "<" in line and ">" in line:
                        flags = line.split("<")[1].split(">")[0].split(",")
                        if "UP" in flags:
                            status = "UP"
                    current = {
                        "name":    name,
                        "mac":     "—",
                        "status":  status,
                        "address": "—",
                    }
                    interfaces.append(current)

                elif current and line.strip().startswith("link/"):
                    # "link/ether 0e:50:b0:77:f2:d1 brd ff:ff:ff:ff:ff:ff"
                    # parts[0]=link/ether  parts[1]=MAC  parts[2]=brd  parts[3]=broadcast
                    parts = line.split()
                    if len(parts) >= 2:
                        current["mac"] = parts[1]

                elif current and line.strip().startswith("inet "):
                    # "inet 172.31.14.50/20 brd 172.31.15.255 scope global ens5"
                    parts = line.split()
                    if len(parts) >= 2 and current["address"] == "—":
                        current["address"] = parts[1].split("/")[0]

        except Exception as e:
            logger.error("Erreur ip addr : %s", e)
        return interfaces

    def _check_ipv6(self) -> bool:
        try:
            with open("/proc/sys/net/ipv6/conf/all/disable_ipv6", "r") as f:
                return f.read().strip() == "0"
        except FileNotFoundError:
            return False

    def _get_mtu(self) -> str:
        try:
            result = subprocess.run(
                ["ip", "link", "show"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode != 0:
                return "—"
            for line in result.stdout.splitlines():
                if "mtu" in line:
                    parts = line.split()
                    idx = parts.index("mtu")
                    return parts[idx + 1]
        except Exception as e:
            logger.error("Erreur MTU : %s", e)
        return "—"
