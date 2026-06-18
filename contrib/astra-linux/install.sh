#!/bin/bash
#
# ZFS installation helper for Astra Linux Special Edition
#
# Usage: sudo bash install.sh
#

set -e

ASTRA_VERSION="$(lsb_release -rs 2>/dev/null || echo unknown)"
KERNEL_VERSION="$(uname -r)"

echo "ZFS installer for Astra Linux ${ASTRA_VERSION} (kernel ${KERNEL_VERSION})"

# Check for root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: this script must be run as root" >&2
    exit 1
fi

# Install build dependencies
apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    dkms \
    "linux-headers-${KERNEL_VERSION}" \
    uuid-dev \
    libblkid-dev \
    libattr1-dev \
    libssl-dev \
    python3-dev \
    python3-setuptools \
    python3-cffi \
    libffi-dev

# Load ZFS module
modprobe zfs && echo "ZFS module loaded successfully"

# Enable ZFS services
systemctl enable --now zfs-import-cache.service \
                       zfs-import-scan.service \
                       zfs-mount.service \
                       zfs-share.service \
                       zfs-zed.service \
                       zfs.target

echo "ZFS installation complete."
echo "Verify with: zpool status && zfs list"
