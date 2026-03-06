#!/bin/bash
# ============================================================
# healthcheck.sh
# Show running VLaaS containers and their access URLs
# ============================================================

HOST_IP=$(hostname -I | awk '{print $1}')

echo "========================================"
echo "  VLaaS — Container Health Check"
echo "  Host IP: $HOST_IP"
echo "========================================"
echo ""

echo "--- Running Containers ---"
sudo docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"

echo ""
echo "--- Access URLs ---"
sudo docker ps --format "{{.Names}} {{.Ports}}" | while read NAME PORTS; do
  # Extract host ports
  HOST_PORTS=$(echo "$PORTS" | grep -oP '0\.0\.0\.0:\K[0-9]+(?=->)' | tr '\n' ',')
  echo "  [$NAME] http://${HOST_IP}:{${HOST_PORTS%,}}"
done

echo ""
echo "--- System Resources ---"
echo "CPU / Memory per container:"
sudo docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
