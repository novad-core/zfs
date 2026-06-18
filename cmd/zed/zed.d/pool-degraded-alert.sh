#!/bin/sh
# shellcheck disable=SC2154
#
# Log an alert when a pool transitions to DEGRADED or FAULTED state.
#
# Writes a structured entry to the audit log and to syslog.
#
# Exit codes:
#   0: alert logged
#   1: logging failed
#   3: event not relevant (pool is healthy)
#   9: internal error

[ -f "${ZED_ZEDLET_DIR}/zed.rc" ] && . "${ZED_ZEDLET_DIR}/zed.rc"
. "${ZED_ZEDLET_DIR}/zed-functions.sh"

[ -n "${ZEVENT_POOL}" ] || exit 9
[ -n "${ZEVENT_POOL_STATE_STR}" ] || exit 9

# Only act on degraded or faulted pools
case "${ZEVENT_POOL_STATE_STR}" in
    DEGRADED|FAULTED|SUSPENDED) ;;
    *) exit 3 ;;
esac

ZFS_AUDIT_LOG="${ZFS_AUDIT_LOG:-/var/log/zfs/audit.log}"
ZFS_AUDIT_DIR="$(dirname "${ZFS_AUDIT_LOG}")"

ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "${ZEVENT_TIME_STRING}")"
host="$(hostname -f 2>/dev/null || hostname)"
msg="Pool '${ZEVENT_POOL}' entered ${ZEVENT_POOL_STATE_STR} state"

# Write to syslog
zed_log_msg "ALERT: ${msg}"

# Write to audit log if configured
if [ -n "${ZFS_AUDIT_LOG}" ]; then
    [ -d "${ZFS_AUDIT_DIR}" ] || mkdir -p "${ZFS_AUDIT_DIR}" 2>/dev/null

    printf '{"ts":"%s","host":"%s","severity":"ALERT","pool":"%s","state":"%s","event":"%s","eid":"%s"}\n' \
        "${ts}" \
        "${host}" \
        "${ZEVENT_POOL}" \
        "${ZEVENT_POOL_STATE_STR}" \
        "${ZEVENT_SUBCLASS}" \
        "${ZEVENT_EID:-0}" \
        >> "${ZFS_AUDIT_LOG}" 2>/dev/null || exit 1
fi

exit 0
