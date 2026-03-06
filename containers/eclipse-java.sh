#!/bin/bash
# ============================================================
# eclipse-java.sh
# Launch Eclipse IDE (Java Workspace) via noVNC
#
# Usage:
#   bash containers/eclipse-java.sh [ubuntu-password] [host-port]
#
# Access: http://<vm-ip>:<host-port>
# ============================================================

UBUNTU_PASS=${1:-ubuntu@123}
VNC_PW=soisvnc@123
HOST_PORT=${2:-6080}

echo "[*] Starting Eclipse IDE (Java) Lab..."
echo "    noVNC Port   : $HOST_PORT"
echo "    Ubuntu Pass  : $UBUNTU_PASS"

sudo docker rm -f vlab-eclipse 2>/dev/null || true

sudo docker run -id -t \
  --name vlab-eclipse \
  -p ${HOST_PORT}:6080 \
  -e UBUNTUPASS=${UBUNTU_PASS} \
  -e VNCPASS=${VNC_PW} \
  sreedocker123/docker-eclipse-novnc

echo ""
echo "[✓] Eclipse IDE Lab running."
echo "    Browser URL : http://$(hostname -I | awk '{print $1}'):${HOST_PORT}"
echo "    Password    : ${UBUNTU_PASS}"
