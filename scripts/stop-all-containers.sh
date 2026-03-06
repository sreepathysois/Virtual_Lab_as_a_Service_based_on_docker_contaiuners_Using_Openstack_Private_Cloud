#!/bin/bash
# ============================================================
# stop-all-containers.sh
# Stop and remove ALL running Docker containers on this host.
# Useful after an exam session to clean up.
#
# Usage:
#   bash scripts/stop-all-containers.sh [--force]
# ============================================================

FORCE=false
if [[ "$1" == "--force" ]]; then
  FORCE=true
fi

echo "========================================"
echo "  VLaaS — Stop All Containers"
echo "========================================"

RUNNING=$(sudo docker ps -q | wc -l)
echo "[*] Running containers: $RUNNING"

if [ "$RUNNING" -eq 0 ]; then
  echo "[✓] No containers running."
  exit 0
fi

if [ "$FORCE" = false ]; then
  echo ""
  read -p "Stop and remove ALL $RUNNING containers? [y/N] " CONFIRM
  if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted."
    exit 0
  fi
fi

echo "[*] Stopping and removing all containers..."
sudo docker rm -f $(sudo docker ps -a -q)

echo ""
echo "[✓] All containers removed."
sudo docker ps
