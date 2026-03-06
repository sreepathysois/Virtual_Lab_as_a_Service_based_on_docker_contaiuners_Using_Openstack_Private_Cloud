#!/bin/bash
# ============================================================
# ml-workspace-gpu.sh
# Launch ML Workspace GPU container (mltooling/ml-workspace-gpu)
# Supports single-user and multi-user (batch) provisioning.
#
# Usage — Single user:
#   bash containers/ml-workspace-gpu.sh <username> <host-port> [gpu-device]
#
# Usage — Batch (reads users from a file):
#   bash containers/ml-workspace-gpu.sh --batch <users-file> [start-port]
#
# Arguments:
#   username    Auth username and workspace folder name
#   host-port   Host port (container always uses 8080 internally)
#   gpu-device  NVIDIA device(s): "all", "0", "1", or a MIG UUID
#               (default: "all")
#
# Access: http://<vm-ip>:<host-port>
# Login:  <username> / <username>@123
# ============================================================

set -e

# ── Batch mode ────────────────────────────────────────────────
if [ "$1" == "--batch" ]; then
  USERS_FILE=${2:-students.txt}
  START_PORT=${3:-7001}

  if [ ! -f "$USERS_FILE" ]; then
    echo "[ERROR] Users file not found: $USERS_FILE"
    exit 1
  fi

  echo "========================================"
  echo "  ML GPU Workspace — Batch Provisioner"
  echo "  Users file : $USERS_FILE"
  echo "  Start port : $START_PORT"
  echo "========================================"

  PORT=$START_PORT
  COUNT=0

  while IFS= read -r USERNAME; do
    [[ -z "$USERNAME" || "$USERNAME" == \#* ]] && continue

    PASS="${USERNAME}@123"
    WORKSPACE="/home/${USERNAME}/workspace"
    mkdir -p "$WORKSPACE"

    sudo docker rm -f "vlab-${USERNAME}" 2>/dev/null || true

    sudo docker run -d \
      --name "vlab-${USERNAME}" \
      -p ${PORT}:8080 \
      --runtime nvidia \
      --env NVIDIA_VISIBLE_DEVICES="all" \
      -v "${WORKSPACE}:/workspace" \
      --env WORKSPACE_AUTH_USER=${USERNAME} \
      --env WORKSPACE_AUTH_PASSWORD=${PASS} \
      --env VNC_PW=${PASS} \
      mltooling/ml-workspace-gpu:0.13.2

    echo "  [✓] ${USERNAME} → http://$(hostname -I | awk '{print $1}'):${PORT}  (pass: ${PASS})"
    PORT=$((PORT + 1))
    COUNT=$((COUNT + 1))
  done < "$USERS_FILE"

  echo ""
  echo "[✓] Provisioned ${COUNT} ML GPU containers."
  exit 0
fi

# ── Single-user mode ──────────────────────────────────────────
USERNAME=${1:-mllab}
HOST_PORT=${2:-7001}
GPU_DEVICE=${3:-all}
PASS="${USERNAME}@123"
WORKSPACE="/home/${USERNAME}/workspace"

mkdir -p "$WORKSPACE"

echo "[*] Starting ML GPU Workspace..."
echo "    User       : $USERNAME"
echo "    Port       : $HOST_PORT"
echo "    GPU device : $GPU_DEVICE"
echo "    Workspace  : $WORKSPACE"

sudo docker rm -f "vlab-${USERNAME}" 2>/dev/null || true

sudo docker run -d \
  --name "vlab-${USERNAME}" \
  -p ${HOST_PORT}:8080 \
  --runtime nvidia \
  --env NVIDIA_VISIBLE_DEVICES="${GPU_DEVICE}" \
  -v "${WORKSPACE}:/workspace" \
  --env WORKSPACE_AUTH_USER=${USERNAME} \
  --env WORKSPACE_AUTH_PASSWORD=${PASS} \
  --env VNC_PW=${PASS} \
  mltooling/ml-workspace-gpu:0.13.2

echo ""
echo "[✓] ML GPU Workspace running."
echo "    Browser URL : http://$(hostname -I | awk '{print $1}'):${HOST_PORT}"
echo "    Username    : ${USERNAME}"
echo "    Password    : ${PASS}"
