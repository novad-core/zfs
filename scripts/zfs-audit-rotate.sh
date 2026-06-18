#!/bin/bash
#
# zfs-audit-rotate.sh - Rotate ZFS audit log files.
#
# Intended to be called from cron or logrotate.
# Keeps up to ZFS_AUDIT_KEEP rotations (default: 7).
#
# Usage: zfs-audit-rotate.sh [--log <path>] [--keep <n>]
#

set -e

ZFS_AUDIT_LOG="${ZFS_AUDIT_LOG:-/var/log/zfs/audit.log}"
ZFS_AUDIT_KEEP=7

while [ "$#" -gt 0 ]; do
    case "$1" in
        --log)  ZFS_AUDIT_LOG="$2"; shift ;;
        --keep) ZFS_AUDIT_KEEP="$2"; shift ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

[ -f "${ZFS_AUDIT_LOG}" ] || exit 0

# Rotate existing backups
i="${ZFS_AUDIT_KEEP}"
while [ "$i" -gt 1 ]; do
    prev=$((i - 1))
    [ -f "${ZFS_AUDIT_LOG}.${prev}" ] && \
        mv -f "${ZFS_AUDIT_LOG}.${prev}" "${ZFS_AUDIT_LOG}.${i}"
    i=$prev
done

# Move current log to .1
mv -f "${ZFS_AUDIT_LOG}" "${ZFS_AUDIT_LOG}.1"

# Compress rotated log
gzip -f "${ZFS_AUDIT_LOG}.1" 2>/dev/null || true

# Remove old rotations beyond keep limit
find "$(dirname "${ZFS_AUDIT_LOG}")" -maxdepth 1 \
    -name "$(basename "${ZFS_AUDIT_LOG}").*" \
    | sort -t. -k2 -n | tail -n "+$((ZFS_AUDIT_KEEP + 1))" \
    | xargs rm -f 2>/dev/null || true

# Signal ZED to reopen log files (if running)
pkill -HUP zed 2>/dev/null || true
