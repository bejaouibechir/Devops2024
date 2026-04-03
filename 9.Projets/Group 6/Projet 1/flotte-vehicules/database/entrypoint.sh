#!/usr/bin/env bash
set -euo pipefail

SQLCMD="/opt/mssql-tools/bin/sqlcmd"
if [ ! -x "$SQLCMD" ] && [ -x "/opt/mssql-tools18/bin/sqlcmd" ]; then
  SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
fi

if [ ! -x "$SQLCMD" ]; then
  echo "sqlcmd introuvable dans l'image SQL Server."
  exit 1
fi

if [ -z "${SA_PASSWORD:-}" ]; then
  echo "La variable d'environnement SA_PASSWORD est requise."
  exit 1
fi

/opt/mssql/bin/sqlservr > /var/opt/mssql/sqlservr.log 2>&1 &
sql_pid=$!

echo "Attente du démarrage de SQL Server..."
for i in {1..60}; do
  if "$SQLCMD" -S localhost -U sa -P "$SA_PASSWORD" -Q "SELECT 1" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

marker="/var/opt/mssql/.flotte_init_done"
if [ ! -f "$marker" ]; then
  echo "Initialisation de FlotteDB via /init.sql..."
  "$SQLCMD" -S localhost -U sa -P "$SA_PASSWORD" -i /init.sql
  touch "$marker"
  echo "Initialisation terminée."
else
  echo "Initialisation déjà effectuée."
fi

wait "$sql_pid"
