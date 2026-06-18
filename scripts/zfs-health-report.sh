#!/bin/bash
#
# zfs-health-report.sh - Generate a structured health report for all ZFS pools.
#
# Usage: zfs-health-report.sh [--json] [--verbose] [--pool <name>]
#
# Exit codes:
#   0: all pools healthy
#   1: one or more pools degraded or faulted
#   2: no pools found

ZPOOL="${ZPOOL:-/sbin/zpool}"
ZFS="${ZFS:-/sbin/zfs}"
JSON=0
VERBOSE=0
POOL_FILTER=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --json)    JSON=1 ;;
        --verbose) VERBOSE=1 ;;
        --pool)    POOL_FILTER="$2"; shift ;;
        *) echo "Unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done

TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
HOSTNAME="$(hostname -f 2>/dev/null || hostname)"
EXIT_CODE=0

pools="$("${ZPOOL}" list -H -o name 2>/dev/null)"
if [ -z "$pools" ]; then
    if [ "$JSON" -eq 1 ]; then
        printf '{"timestamp":"%s","host":"%s","pools":[],"status":"no_pools"}\n' \
            "$TIMESTAMP" "$HOSTNAME"
    else
        echo "No ZFS pools found."
    fi
    exit 2
fi

if [ "$JSON" -eq 1 ]; then
    printf '{"timestamp":"%s","host":"%s","pools":[\n' "$TIMESTAMP" "$HOSTNAME"
    first=1
fi

for pool in $pools; do
    [ -n "$POOL_FILTER" ] && [ "$pool" != "$POOL_FILTER" ] && continue

    state="$("${ZPOOL}" list -H -o health "$pool" 2>/dev/null)"
    size="$("${ZPOOL}" list -H -o size "$pool" 2>/dev/null)"
    alloc="$("${ZPOOL}" list -H -o alloc "$pool" 2>/dev/null)"
    free="$("${ZPOOL}" list -H -o free "$pool" 2>/dev/null)"
    frag="$("${ZPOOL}" list -H -o frag "$pool" 2>/dev/null)"
    errors="$("${ZPOOL}" status "$pool" 2>/dev/null | grep -c 'DEGRADED\|FAULTED\|OFFLINE\|REMOVED' || true)"
    scrub_date="$("${ZPOOL}" status "$pool" 2>/dev/null | grep 'scan:' | awk '{print $4,$5,$6,$7,$8}' || echo 'never')"

    [ "$state" != "ONLINE" ] && EXIT_CODE=1

    if [ "$JSON" -eq 1 ]; then
        [ "$first" -eq 0 ] && printf ','
        printf '{"pool":"%s","state":"%s","size":"%s","alloc":"%s","free":"%s","frag":"%s","last_scrub":"%s"}' \
            "$pool" "$state" "$size" "$alloc" "$free" "$frag" "$scrub_date"
        first=0
    else
        printf "Pool: %-20s  State: %-10s  Size: %s  Alloc: %s  Free: %s  Frag: %s\n" \
            "$pool" "$state" "$size" "$alloc" "$free" "$frag"
        if [ "$VERBOSE" -eq 1 ]; then
            echo "  Last scrub: ${scrub_date:-never}"
            "${ZPOOL}" status -v "$pool" 2>/dev/null | grep -E 'DEGRADED|FAULTED|errors:' || true
            echo ""
        fi
    fi
done

if [ "$JSON" -eq 1 ]; then
    printf '],"overall":"%s"}\n' "$([ "$EXIT_CODE" -eq 0 ] && echo HEALTHY || echo DEGRADED)"
fi

exit "$EXIT_CODE"
