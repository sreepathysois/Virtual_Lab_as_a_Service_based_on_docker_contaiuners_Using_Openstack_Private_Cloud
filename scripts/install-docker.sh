#!/bin/bash
# ============================================================
# install-docker.sh
# Install Docker CE on Ubuntu 20.04 / 22.04 VM
# Usage: bash scripts/install-docker.sh
# ============================================================

set -e

echo "========================================"
echo "  VLaaS — Docker CE Installer"
echo "========================================"

# Update package index
sudo apt-get update -y

# Install prerequisites
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
echo "[*] Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up the stable repository
echo "[*] Adding Docker apt repository..."
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker CE
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to docker group (avoid sudo for docker commands)
sudo usermod -aG docker $USER

echo ""
echo "[✓] Docker installed successfully!"
sudo systemctl status docker --no-pager

echo ""
echo "NOTE: Log out and back in (or run 'newgrp docker') to use docker without sudo."
