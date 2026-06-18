#!/bin/sh
# shellcheck disable=SC2154
#
# Write a structured audit log entry for ZFS pool events.
#
# Events are recorded as JSON lines to ZFS_AUDIT_LOG (default:
# /var/log/zfs/audit.log). Each entry contains a timestamp, hostname,
# pool name, event subclass and pool state.
#
# Exit codes:
#   0: audit entry written
#   1: write failed
#   2: audit logging not configured
#   9: internal error

[ -f "${ZED_ZEDLET_DIR}/zed.rc" ] && . "${ZED_ZEDLET_DIR}/zed.rc"
. "${ZED_ZEDLET_DIR}/zed-functions.sh"

[ -n "${ZEVENT_POOL}" ] || exit 9
[ -n "${ZEVENT_SUBCLASS}" ] || exit 9

ZFS_AUDIT_LOG="${ZFS_AUDIT_LOG:-/var/log/zfs/audit.log}"
ZFS_AUDIT_DIR="$(dirname "${ZFS_AUDIT_LOG}")"

[ "${ZFS_AUDIT_ENABLED:-1}" = "1" ] || exit 2

if [ ! -d "${ZFS_AUDIT_DIR}" ]; then
    mkdir -p "${ZFS_AUDIT_DIR}" 2>/dev/null || exit 1
fi

ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "${ZEVENT_TIME_STRING}")"
host="$(hostname -f 2>/dev/null || hostname)"

printf '{"ts":"%s","host":"%s","pool":"%s","event":"%s","state":"%s","eid":"%s"}\n' \
    "${ts}" \
    "${host}" \
    "${ZEVENT_POOL}" \
    "${ZEVENT_SUBCLASS}" \
    "${ZEVENT_POOL_STATE_STR:-unknown}" \
    "${ZEVENT_EID:-0}" \
    >> "${ZFS_AUDIT_LOG}" 2>/dev/null || exit 1

exit 0
