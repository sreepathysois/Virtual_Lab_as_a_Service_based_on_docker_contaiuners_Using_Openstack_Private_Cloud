#!/bin/bash
# ============================================================
# setup-nginx.sh
# Install NGINX and deploy VLaaS reverse proxy config
# ============================================================

set -e

echo "[*] Installing NGINX..."
sudo apt-get update -y
sudo apt-get install -y nginx apache2-utils

echo "[*] Copying VLaaS proxy config..."
sudo cp vlab-proxy.conf /etc/nginx/conf.d/vlab-proxy.conf
sudo cp nginx.conf /etc/nginx/nginx.conf

echo "[*] Testing NGINX config..."
sudo nginx -t

echo "[*] Reloading NGINX..."
sudo systemctl enable nginx
sudo systemctl reload nginx

echo ""
echo "[✓] NGINX configured and running."
echo ""
echo "To add basic auth for exam mode:"
echo "  sudo htpasswd -c /etc/nginx/.htpasswd <username>"
echo "Then uncomment the auth_basic lines in vlab-proxy.conf and reload NGINX."
