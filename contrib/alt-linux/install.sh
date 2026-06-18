#!/bin/bash
#
# ZFS installation helper for ALT Linux / ALT Server
#
# Usage: sudo bash install.sh
#

set -e

ALT_VERSION="$(lsb_release -rs 2>/dev/null || cat /etc/altlinux-release 2>/dev/null | awk '{print $NF}' || echo unknown)"
KERNEL_VERSION="$(uname -r)"

echo "ZFS installer for ALT Linux ${ALT_VERSION} (kernel ${KERNEL_VERSION})"

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: this script must be run as root" >&2
    exit 1
fi

# Install build dependencies via apt-get (ALT uses apt)
apt-get install -y \
    kernel-headers-modules-std-def \
    libuuid-devel \
    libblkid-devel \
    libattr-devel \
    openssl-devel \
    python3-devel \
    python3-module-setuptools \
    python3-module-cffi \
    libffi-devel \
    gcc \
    make \
    automake \
    autoconf \
    libtool

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

# Autoload on boot
echo "zfs" > /etc/modules-load.d/zfs.conf

echo "ZFS installation complete."
echo "Verify with: zpool status && zfs list"
