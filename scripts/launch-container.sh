#!/bin/bash
# ============================================================
# launch-container.sh
# Unified launcher for VLaaS lab environments
#
# Usage:
#   bash scripts/launch-container.sh <env> [options]
#
# Environments:
#   linux       Ubuntu XFCE + SQLite (noVNC)
#   vscode      Ubuntu + VS Code + .NET SDK
#   eclipse     Eclipse IDE (Java)
#   rstudio     RStudio (R / Statistics / AIML)
#   jupyter     Jupyter Notebook (AIML / Data Science)
#   mlgpu       ML Workspace GPU (multi-user)
#   android     Android Emulator
#   centos      CentOS GNOME VNC
#
# Options:
#   --user <username>     Username for ML workspace (default: mllab)
#   --port <port>         Host port override (default: per-environment)
#   --password <pass>     Password override
#   --data <path>         Host path to mount as /data in container
# ============================================================

set -e

ENV=$1
shift

# Defaults
USERNAME="mllab"
PORT=""
PASSWORD=""
DATA_PATH=""

# Parse optional args
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --user) USERNAME="$2"; shift ;;
        --port) PORT="$2"; shift ;;
        --password) PASSWORD="$2"; shift ;;
        --data) DATA_PATH="$2"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

echo "========================================"
echo "  VLaaS — Container Launcher"
echo "  Environment: $ENV"
echo "========================================"

case "$ENV" in

  linux)
    HOST_PORT=${PORT:-6901}
    VNC_PW=${PASSWORD:-soisvnc@123}
    echo "[*] Launching Ubuntu XFCE + SQLite lab on port $HOST_PORT..."
    sudo docker run -d \
      -p 5901:5901 \
      -p ${HOST_PORT}:6901 \
      -e VNC_PW=${VNC_PW} \
      --name vlab-linux \
      jiteshsojitra/docker-ubuntu-xfce-container
    echo "[✓] Access: http://$(hostname -I | awk '{print $1}'):${HOST_PORT}/vnc.html"
    ;;

  vscode)
    HOST_VNC=${PORT:-5901}
    HOST_NOVNC=6901
    VNC_PW=${PASSWORD:-soisvnc@123}
    echo "[*] Launching Ubuntu + VS Code + .NET lab..."
    sudo docker run -it -d \
      -p ${HOST_VNC}:5901 \
      -p ${HOST_NOVNC}:6901 \
      --user root \
      -e VNC_PW=${VNC_PW} \
      --name vlab-vscode \
      sreedocker123/ubuntuvscodedotnet:latest
    echo "[✓] VNC: $(hostname -I | awk '{print $1}'):${HOST_VNC}"
    echo "[✓] noVNC: http://$(hostname -I | awk '{print $1}'):${HOST_NOVNC}/vnc.html"
    ;;

  eclipse)
    HOST_PORT=${PORT:-6080}
    UBUNTUPASS=${PASSWORD:-ubuntu@123}
    VNC_PW=soisvnc@123
    echo "[*] Launching Eclipse IDE (Java) lab on port $HOST_PORT..."
    sudo docker run -id -t \
      -p ${HOST_PORT}:6080 \
      -e UBUNTUPASS=${UBUNTUPASS} \
      -e VNCPASS=${VNC_PW} \
      --name vlab-eclipse \
      sreedocker123/docker-eclipse-novnc
    echo "[✓] Access: http://$(hostname -I | awk '{print $1}'):${HOST_PORT}"
    ;;

  rstudio)
    HOST_PORT=${PORT:-8787}
    RPASS=${PASSWORD:-soisrstudio@123}
    DATA_MOUNT=""
    if [ -n "$DATA_PATH" ]; then
      DATA_MOUNT="-v ${DATA_PATH}:/home/rstudio/Data"
    fi
    echo "[*] Launching RStudio lab on port $HOST_PORT..."
    sudo docker run --rm -d \
      -p ${HOST_PORT}:8787 \
      -e PASSWORD=${RPASS} \
      ${DATA_MOUNT} \
      --name vlab-rstudio \
      rocker/verse
    echo "[✓] Access: http://$(hostname -I | awk '{print $1}'):${HOST_PORT}"
    echo "    Login: rstudio / ${RPASS}"
    ;;

  jupyter)
    HOST_PORT=${PORT:-8888}
    TOKEN=${PASSWORD:-msois@123}
    DATA_MOUNT=""
    if [ -n "$DATA_PATH" ]; then
      DATA_MOUNT="-v ${DATA_PATH}:/home/jovyan/Data"
    fi
    echo "[*] Launching Jupyter Notebook on port $HOST_PORT..."
    sudo docker run -it -d \
      -p ${HOST_PORT}:8888 \
      --name vlab-jupyter \
      -e JUPYTER_TOKEN=${TOKEN} \
      ${DATA_MOUNT} \
      jupyter/scipy-notebook:83ed2c63671f
    echo "[✓] Access: http://$(hostname -I | awk '{print $1}'):${HOST_PORT}"
    echo "    Token: ${TOKEN}"
    ;;

  mlgpu)
    HOST_PORT=${PORT:-7001}
    PASS=${PASSWORD:-${USERNAME}@123}
    WORKSPACE="/home/${USERNAME}/workspace"
    mkdir -p ${WORKSPACE}
    echo "[*] Launching ML GPU Workspace for user '${USERNAME}' on port ${HOST_PORT}..."
    sudo docker run -d \
      -p ${HOST_PORT}:8080 \
      --runtime nvidia \
      --env NVIDIA_VISIBLE_DEVICES="all" \
      -v "${WORKSPACE}:/workspace" \
      --env WORKSPACE_AUTH_USER=${USERNAME} \
      --env WORKSPACE_AUTH_PASSWORD=${PASS} \
      --env VNC_PW=${PASS} \
      --name vlab-mlgpu-${USERNAME} \
      mltooling/ml-workspace-gpu:0.13.2
    echo "[✓] Access: http://$(hostname -I | awk '{print $1}'):${HOST_PORT}"
    echo "    User: ${USERNAME} | Password: ${PASS}"
    ;;

  android)
    HOST_PORT=${PORT:-6080}
    echo "[*] Launching Android Emulator on port $HOST_PORT..."
    sudo docker run --privileged -d \
      -p ${HOST_PORT}:6080 \
      -p 5554:5554 \
      -p 5555:5555 \
      -e DEVICE="Samsung Galaxy S6" \
      --name vlab-android \
      budtmo/docker-android-x86-8.1
    echo "[✓] Access: http://$(hostname -I | awk '{print $1}'):${HOST_PORT}"
    ;;

  centos)
    HOST_VNC=${PORT:-5903}
    echo "[*] Launching CentOS GNOME VNC on port $HOST_VNC..."
    sudo docker run -d \
      -p ${HOST_VNC}:5901 \
      -p 6901:6901 \
      --user 0 \
      --privileged=true \
      --name vlab-centos \
      consol/centos-xfce-vnc
    echo "[✓] VNC: $(hostname -I | awk '{print $1}'):${HOST_VNC}"
    ;;

  *)
    echo "Unknown environment: $ENV"
    echo ""
    echo "Available environments:"
    echo "  linux, vscode, eclipse, rstudio, jupyter, mlgpu, android, centos"
    exit 1
    ;;

esac

echo ""
echo "[✓] Container launched. Run 'sudo docker ps' to verify."
