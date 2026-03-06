#!/bin/bash
# ============================================================
# linux-lab.sh
# Launch Ubuntu XFCE + SQLite lab environment via noVNC
#
# Usage:
#   bash containers/linux-lab.sh [vnc-password] [host-port]
#
# Access: http://<vm-ip>:<host-port>/vnc.html
# ============================================================

VNC_PW=${1:-soisvnc@123}
HOST_PORT=${2:-6901}
VNC_PORT=5901

echo "[*] Starting Ubuntu XFCE + SQLite Lab..."
echo "    noVNC Port : $HOST_PORT"
echo "    VNC Port   : $VNC_PORT"
echo "    VNC Pass   : $VNC_PW"

sudo docker rm -f vlab-linux 2>/dev/null || true

sudo docker run -d \
  --name vlab-linux \
  -p ${VNC_PORT}:5901 \
  -p ${HOST_PORT}:6901 \
  -e VNC_PW=${VNC_PW} \
  jiteshsojitra/docker-ubuntu-xfce-container

echo ""
echo "[✓] Linux Lab running."
echo "    Browser URL : http://$(hostname -I | awk '{print $1}'):${HOST_PORT}/vnc.html"
echo ""
echo "--- Post-launch: Install SQLite inside container ---"
echo "    sudo docker exec -it vlab-linux bash"
echo "    apt-get update && apt-get install -y sqlite3 sqlitebrowser"
