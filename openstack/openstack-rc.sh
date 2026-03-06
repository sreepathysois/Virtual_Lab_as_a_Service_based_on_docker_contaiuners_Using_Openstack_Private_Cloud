# ============================================================
# openstack-rc.sh
# OpenStack environment variables — source this before using
# the OpenStack CLI or create-vm.sh
#
# Usage:
#   source openstack/openstack-rc.sh
#
# Replace all <PLACEHOLDER> values with your actual credentials.
# ============================================================

export OS_AUTH_URL=http://<keystone-ip>:5000/v3
export OS_PROJECT_NAME="<your-project>"
export OS_USERNAME="<your-username>"
export OS_PASSWORD="<your-password>"
export OS_USER_DOMAIN_NAME="Default"
export OS_PROJECT_DOMAIN_NAME="Default"
export OS_REGION_NAME="RegionOne"
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3

echo "[✓] OpenStack environment variables loaded for project: $OS_PROJECT_NAME"
