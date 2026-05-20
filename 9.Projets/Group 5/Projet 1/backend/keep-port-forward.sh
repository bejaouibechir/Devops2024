#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="mysql-app"
SERVICE="flask-backend"
LOCAL_PORT="5000"
POD_PORT="5000"

check_port_listening() {
    ss -tuln | grep -q ":$LOCAL_PORT " || netstat -tuln 2>/dev/null | grep -q ":$LOCAL_PORT "
}

while true; do
    if check_port_listening; then
        echo "[$(date '+%H:%M:%S')] Port $LOCAL_PORT semble OK → sleep 15s"
        sleep 15
        continue
    fi

    echo "[$(date '+%H:%M:%S')] Port $LOCAL_PORT fermé → relance port-forward"

    kubectl port-forward \
        -n "$NAMESPACE" \
        svc/"$SERVICE" \
        "$LOCAL_PORT:$POD_PORT" \
        --address 0.0.0.0 \
        --pod-running-timeout=48h \
        --request-timeout=0 2>&1 | sed 's/^/  | /' &

    sleep 4  # laisser le temps de démarrer
done
