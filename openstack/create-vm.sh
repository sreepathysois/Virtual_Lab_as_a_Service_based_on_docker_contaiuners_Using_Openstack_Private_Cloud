#!/bin/bash
# ============================================================
# create-vm.sh
# Launch a new OpenStack VM for VLaaS using the OpenStack CLI
#
# Prerequisites:
#   - OpenStack CLI installed: pip install python-openstackclient
#   - Source your OpenStack RC file first:
#       source openstack-rc.sh
#
# Usage:
#   bash openstack/create-vm.sh <vm-name> [flavor] [image]
# ============================================================

set -e

VM_NAME=${1:-vlab-node-01}
FLAVOR=${2:-m1.xlarge}          # 8 vCPU, 16 GB RAM recommended
IMAGE=${3:-Ubuntu-22.04}
NETWORK=${4:-vlab-network}
KEY_PAIR=${5:-vlab-key}
SECURITY_GROUP=${6:-vlab-sg}

echo "========================================"
echo "  VLaaS — OpenStack VM Provisioner"
echo "  VM Name  : $VM_NAME"
echo "  Flavor   : $FLAVOR"
echo "  Image    : $IMAGE"
echo "  Network  : $NETWORK"
echo "========================================"

# Create security group (if not exists)
openstack security group show $SECURITY_GROUP &>/dev/null || {
  echo "[*] Creating security group: $SECURITY_GROUP"
  openstack security group create $SECURITY_GROUP \
    --description "VLaaS Lab Security Group"

  # SSH
  openstack security group rule create $SECURITY_GROUP \
    --protocol tcp --dst-port 22 --remote-ip 0.0.0.0/0

  # noVNC / Web access ports (6080, 6901, 7001-7020, 8080, 8787, 8888)
  for PORT in 6080 6901 8080 8787 8888; do
    openstack security group rule create $SECURITY_GROUP \
      --protocol tcp --dst-port $PORT --remote-ip 0.0.0.0/0
  done

  # ML workspace range
  openstack security group rule create $SECURITY_GROUP \
    --protocol tcp --dst-port 7001:7020 --remote-ip 0.0.0.0/0

  echo "[✓] Security group created."
}

# Launch VM
echo "[*] Launching VM..."
openstack server create \
  --flavor $FLAVOR \
  --image $IMAGE \
  --network $NETWORK \
  --key-name $KEY_PAIR \
  --security-group $SECURITY_GROUP \
  --wait \
  $VM_NAME

echo ""
echo "[✓] VM launched: $VM_NAME"
openstack server show $VM_NAME --format table \
  -c name -c status -c addresses -c flavor

echo ""
echo "Next steps:"
echo "  1. Assign a floating IP: openstack floating ip create <ext-net>"
echo "  2. Associate it: openstack server add floating ip $VM_NAME <floating-ip>"
echo "  3. SSH: ssh ubuntu@<floating-ip> -i <key.pem>"
echo "  4. Run: bash scripts/install-docker.sh"
