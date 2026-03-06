#!/bin/bash
# ============================================================
# centos-gnome.sh
# Launch CentOS XFCE/GNOME VNC lab environment
#
# Usage:
#   bash containers/centos-gnome.sh [vnc-port] [novnc-port]
#
# Arguments:
#   vnc-port    Host port for raw VNC access (default: 5903)
#   novnc-port  Host port for noVNC browser access (default: 6901)
#
# Access (noVNC): http://<vm-ip>:<novnc-port>/vnc.html
# Access (VNC):   <vm-ip>:<vnc-port>
# ============================================================

VNC_PORT=${1:-5903}
NOVNC_PORT=${2:-6901}

echo "[*] Starting CentOS GNOME/XFCE VNC Lab..."
echo "    VNC Port   : $VNC_PORT"
echo "    noVNC Port : $NOVNC_PORT"

sudo docker rm -f vlab-centos 2>/dev/null || true

sudo docker run -d \
  --name vlab-centos \
  -p ${VNC_PORT}:5901 \
  -p ${NOVNC_PORT}:6901 \
  --user 0 \
  --privileged=true \
  consol/centos-xfce-vnc

echo ""
echo "[✓] CentOS GNOME Lab running."
echo "    noVNC URL  : http://$(hostname -I | awk '{print $1}'):${NOVNC_PORT}/vnc.html"
echo "    VNC Client : $(hostname -I | awk '{print $1}'):${VNC_PORT}"
echo ""
echo "NOTE: Default VNC password set by the image. Check consol/centos-xfce-vnc docs."
