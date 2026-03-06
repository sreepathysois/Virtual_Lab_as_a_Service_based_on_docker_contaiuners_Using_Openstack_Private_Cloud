#!/bin/bash
# ============================================================
# android-emulator.sh
# Launch Android Emulator via Docker (budtmo/docker-android)
#
# Usage:
#   bash containers/android-emulator.sh [device-name] [host-port]
#
# Arguments:
#   device-name   Android device to emulate (default: "Samsung Galaxy S6")
#   host-port     Port for noVNC browser access (default: 6080)
#
# Access: http://<vm-ip>:<host-port>
# ADB:    adb connect <vm-ip>:5555
# ============================================================

DEVICE=${1:-Samsung Galaxy S6}
HOST_PORT=${2:-6080}

echo "[*] Starting Android Emulator..."
echo "    Device     : $DEVICE"
echo "    noVNC Port : $HOST_PORT"
echo "    ADB Port   : 5555"
echo "    Appium Port: 4723"

sudo docker rm -f vlab-android 2>/dev/null || true

sudo docker run --privileged -d \
  --name vlab-android \
  -p ${HOST_PORT}:6080 \
  -p 5554:5554 \
  -p 5555:5555 \
  -p 4723:4723 \
  -e DEVICE="${DEVICE}" \
  budtmo/docker-android-x86-8.1

echo ""
echo "[✓] Android Emulator running."
echo "    Browser URL : http://$(hostname -I | awk '{print $1}'):${HOST_PORT}"
echo "    ADB connect : adb connect $(hostname -I | awk '{print $1}'):5555"
echo ""
echo "NOTE: Emulator takes 60-90 seconds to fully boot. Wait before accessing."
