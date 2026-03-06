#!/bin/bash
# ============================================================
# rstudio.sh
# Launch RStudio (rocker/verse) lab environment
#
# Usage:
#   bash containers/rstudio.sh [password] [host-port] [data-path]
#
# Arguments:
#   password   RStudio login password (default: soisrstudio@123)
#   host-port  Port to expose RStudio on (default: 8787)
#   data-path  Optional host path to mount as /home/rstudio/Data
#
# Access: http://<vm-ip>:<host-port>
# Login:  rstudio / <password>
# ============================================================

RPASS=${1:-soisrstudio@123}
HOST_PORT=${2:-8787}
DATA_PATH=${3:-}

VOLUME_ARG=""
if [ -n "$DATA_PATH" ]; then
  mkdir -p "$DATA_PATH"
  VOLUME_ARG="-v ${DATA_PATH}:/home/rstudio/Data"
  echo "    Data mount : $DATA_PATH → /home/rstudio/Data"
fi

echo "[*] Starting RStudio Lab..."
echo "    Port     : $HOST_PORT"
echo "    Password : $RPASS"

sudo docker rm -f vlab-rstudio 2>/dev/null || true

sudo docker run --rm -d \
  --name vlab-rstudio \
  -p ${HOST_PORT}:8787 \
  -e PASSWORD=${RPASS} \
  ${VOLUME_ARG} \
  rocker/verse

echo ""
echo "[✓] RStudio Lab running."
echo "    Browser URL : http://$(hostname -I | awk '{print $1}'):${HOST_PORT}"
echo "    Username    : rstudio"
echo "    Password    : ${RPASS}"
