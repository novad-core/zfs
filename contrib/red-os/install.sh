#!/bin/bash
#
# ZFS installation helper for RED OS
#
# Usage: sudo bash install.sh
#

set -e

REDOS_VERSION="$(rpm -q --qf '%{VERSION}' redos-release 2>/dev/null || echo unknown)"
KERNEL_VERSION="$(uname -r)"

echo "ZFS installer for RED OS ${REDOS_VERSION} (kernel ${KERNEL_VERSION})"

# Check for root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: this script must be run as root" >&2
    exit 1
fi

# Enable EPEL if not already enabled
if ! rpm -q epel-release &>/dev/null; then
    dnf install -y epel-release
fi

# Install build dependencies
dnf install -y \
    autoconf \
    automake \
    libtool \
    rpm-build \
    "kernel-devel-${KERNEL_VERSION}" \
    libuuid-devel \
    libblkid-devel \
    libattr-devel \
    openssl-devel \
    python3-devel \
    python3-setuptools \
    python3-cffi \
    libffi-devel \
    dkms

# Load ZFS module
modprobe zfs && echo "ZFS module loaded successfully"

# Enable ZFS services
systemctl enable --now \
    zfs-import-cache.service \
    zfs-import-scan.service \
    zfs-mount.service \
    zfs-share.service \
    zfs-zed.service \
    zfs.target

# Add ZFS module to autoload
echo "zfs" > /etc/modules-load.d/zfs.conf

echo "ZFS installation complete."
echo "Verify with: zpool status && zfs list"
