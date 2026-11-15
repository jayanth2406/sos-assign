#!/usr/bin/env bash
# Inspect only a process that the current user is permitted to inspect.
set -u

if [[ $# -ne 1 || ! $1 =~ ^[0-9]+$ ]]; then
    echo "Usage: $0 <PID>" >&2
    exit 2
fi
pid=$1
proc="/proc/$pid"
if [[ ! -d $proc ]]; then
    echo "Process $pid does not exist." >&2
    exit 1
fi

echo "PID: $pid"
printf 'Command: '
if [[ -r $proc/cmdline ]]; then
    tr '\0' ' ' < "$proc/cmdline"
fi
printf '\n'
grep -E '^(Name|State|PPid|Uid|Gid|Threads|VmSize|VmRSS|CapEff):' "$proc/status" || exit 1
fd_count=$(find "$proc/fd" -mindepth 1 -maxdepth 1 -printf '.' 2>/dev/null | wc -c)
echo "Open file descriptors: $fd_count"

# Linux start time (clock ticks since boot), taken from /proc/PID/stat. The
# command name is parenthesized and may contain spaces, so parse after its last ')'.
if [[ -r $proc/stat ]]; then
    stat_line=$(<"$proc/stat")
    stat_fields=${stat_line##*) }
    read -r -a fields <<< "$stat_fields"
    # stat_fields starts at field 3 (state); starttime is field 22 (index 19).
    if ((${#fields[@]} > 19)); then
        echo "Start time (clock ticks since boot): ${fields[19]}"
    fi
fi
