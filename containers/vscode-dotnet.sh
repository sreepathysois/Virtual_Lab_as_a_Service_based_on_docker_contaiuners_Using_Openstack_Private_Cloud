#!/bin/bash
# ============================================================
# vscode-dotnet.sh
# Launch Ubuntu 22.04 + VS Code + .NET SDK 8.0 lab via VNC/noVNC
#
# Usage:
#   bash containers/vscode-dotnet.sh [vnc-password] [vnc-port] [novnc-port]
#
# Access (noVNC): http://<vm-ip>:<novnc-port>/vnc.html
# Access (VNC client): <vm-ip>:<vnc-port>
# ============================================================

VNC_PW=${1:-soisvnc@123}
VNC_PORT=${2:-5901}
NOVNC_PORT=${3:-6901}

echo "[*] Starting Ubuntu + VS Code + .NET SDK Lab..."
echo "    VNC Port   : $VNC_PORT"
echo "    noVNC Port : $NOVNC_PORT"
echo "    VNC Pass   : $VNC_PW"

sudo docker rm -f vlab-vscode 2>/dev/null || true

sudo docker run -it -d \
  --name vlab-vscode \
  -p ${VNC_PORT}:5901 \
  -p ${NOVNC_PORT}:6901 \
  --user root \
  -e VNC_PW=${VNC_PW} \
  sreedocker123/ubuntuvscodedotnet:latest

echo ""
echo "[✓] VS Code + .NET Lab running."
echo "    noVNC URL  : http://$(hostname -I | awk '{print $1}'):${NOVNC_PORT}/vnc.html"
echo "    VNC Client : $(hostname -I | awk '{print $1}'):${VNC_PORT}"
echo "    Password   : ${VNC_PW}"
