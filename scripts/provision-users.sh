#!/bin/bash
# ============================================================
# provision-users.sh
# Batch-provision one ML GPU workspace container per student
#
# Usage:
#   bash scripts/provision-users.sh <users-file> [start-port]
#
# users-file format (one username per line):
#   student1
#   student2
#   ...
#
# Containers are assigned sequential ports starting from start-port (default: 7001)
# Each student gets:
#   - Container named vlab-<username>
#   - Port: start-port + index
#   - Workspace mounted at /home/<username>/workspace
#   - Auth: <username> / <username>@123
# ============================================================

set -e

USERS_FILE=${1:-users.txt}
START_PORT=${2:-7001}

if [ ! -f "$USERS_FILE" ]; then
  echo "[ERROR] Users file not found: $USERS_FILE"
  echo "Create a file with one username per line."
  exit 1
fi

echo "========================================"
echo "  VLaaS — Batch User Provisioner"
echo "  Users file : $USERS_FILE"
echo "  Start port : $START_PORT"
echo "========================================"
echo ""

PORT=$START_PORT
INDEX=0

while IFS= read -r USERNAME; do
  # Skip empty lines and comments
  [[ -z "$USERNAME" || "$USERNAME" == \#* ]] && continue

  PASS="${USERNAME}@123"
  WORKSPACE="/home/${USERNAME}/workspace"
  CONTAINER_NAME="vlab-${USERNAME}"

  # Create workspace directory
  mkdir -p "${WORKSPACE}"

  echo "[*] Provisioning: ${USERNAME} → port ${PORT}"

  # Remove existing container if any
  sudo docker rm -f ${CONTAINER_NAME} 2>/dev/null || true

  sudo docker run -d \
    -p ${PORT}:8080 \
    --runtime nvidia \
    --env NVIDIA_VISIBLE_DEVICES="all" \
    -v "${WORKSPACE}:/workspace" \
    --env WORKSPACE_AUTH_USER=${USERNAME} \
    --env WORKSPACE_AUTH_PASSWORD=${PASS} \
    --env VNC_PW=${PASS} \
    --name ${CONTAINER_NAME} \
    mltooling/ml-workspace-gpu:0.13.2

  echo "    [✓] http://$(hostname -I | awk '{print $1}'):${PORT}  (${USERNAME} / ${PASS})"

  PORT=$((PORT + 1))
  INDEX=$((INDEX + 1))

done < "$USERS_FILE"

echo ""
echo "========================================"
echo "  Provisioned ${INDEX} containers."
echo "  Run 'sudo docker ps' to verify."
echo "========================================"
