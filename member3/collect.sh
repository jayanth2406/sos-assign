#!/usr/bin/env bash
# Read-only evidence collector for SecureLab Missions 15–21.
# Run on the authorized Linux target. No sudo, package installs, service changes,
# containers, network connections, or policy changes are performed.
set -u

section() { printf '\n\n===== %s =====\n' "$1"; }
run() {
    printf '\n$'
    printf ' %q' "$@"
    printf '\n'
    "$@" 2>&1 || printf '[exit status %s]\n' "$?"
}
available() { command -v "$1" >/dev/null 2>&1; }

section 'Collection metadata'
run date -Is
run uname -a
run cat /etc/os-release
printf '\nCollector performs read-only inspection. No target state is changed.\n'

section 'Mission 15: owned sleep process resource inspection'
if available sleep && available ps && [ -d /proc/self/fd ]; then
    sleep 60 &
    pid=$!
    trap 'kill "$pid" 2>/dev/null || true' EXIT INT TERM
    printf 'Collector-owned sleep PID: %s\n' "$pid"
    run ps -p "$pid" -o pid,ppid,uid,euid,nlwp,%cpu,%mem,cmd
    run ls -l "/proc/$pid/fd"
    run grep -E '^(Name|Uid|Gid|Threads):' "/proc/$pid/status"
    if available ss; then
        printf '\n$ ss -lntup (host-wide; correlate program/PID before attribution)\n'
        ss -lntup 2>&1 || printf '[exit status %s]\n' "$?"
    else
        printf 'ss is unavailable\n'
    fi
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
    trap - EXIT INT TERM
else
    printf 'Required sleep/ps/proc interfaces unavailable; no process launched.\n'
fi

section 'Mission 16: Docker status only (no daemon start or container run)'
if available docker; then
    run docker --version
    printf '\n$ docker info --format ... (may be denied when daemon is stopped/inaccessible)\n'
    docker info --format 'ServerVersion={{.ServerVersion}} Driver={{.Driver}} CgroupVersion={{.CgroupVersion}}' 2>&1 || printf '[exit status %s]\n' "$?"
else
    printf 'docker CLI unavailable\n'
fi

section 'Mission 17: AppArmor status and loaded profiles'
if [ -r /sys/module/apparmor/parameters/enabled ]; then
    run cat /sys/module/apparmor/parameters/enabled
else
    printf '/sys/module/apparmor/parameters/enabled unavailable\n'
fi
if available aa-status; then
    run aa-status
else
    printf 'aa-status unavailable\n'
fi
if available aa-unconfined; then
    printf '\n$ aa-unconfined (first 20 lines; may require privileges)\n'
    aa-unconfined 2>&1 | head -20
    printf '[pipeline status is not a policy test]\n'
else
    printf 'aa-unconfined unavailable\n'
fi

section 'Mission 18: conceptual comparison'
printf 'See Missions-15-22.md for DAC/MAC/RBAC/ACL/capability comparison and answers.\n'

section 'Mission 19: read-only hardening baseline'
if available apt; then
    printf '\n$ apt list --upgradable (uses current local package metadata; does not refresh it)\n'
    apt list --upgradable 2>&1 | head -30
else
    printf 'apt unavailable\n'
fi
if available systemctl; then
    run systemctl --type=service --state=running --no-pager
else
    printf 'systemctl unavailable\n'
fi
if available ss; then run ss -lntup; else printf 'ss unavailable\n'; fi
if available ufw; then run ufw status verbose; else printf 'ufw command unavailable\n'; fi

section 'Mission 20: SSH server status and non-secret configuration metadata'
if available sshd; then
    run sshd -V
else
    printf 'sshd executable unavailable\n'
fi
if available systemctl; then
    run systemctl is-active ssh
    run systemctl is-active sshd
    run systemctl is-enabled ssh
    run systemctl is-enabled sshd
else
    printf 'systemctl unavailable\n'
fi
if available ss; then
    printf '\n$ ss -ltn (check whether local port 22 is listening)\n'
    ss -ltn 2>&1 | awk 'NR == 1 || $4 ~ /:22$/ {print}'
else
    printf 'ss unavailable\n'
fi
printf '\nSSH config file metadata and directive names only (values are not printed):\n'
for cfg in /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf; do
    [ -f "$cfg" ] || continue
    if available stat; then stat -c '%a %U:%G %n' "$cfg" 2>&1 || true; else printf '%s\n' "$cfg"; fi
    awk '
        /^[[:space:]]*#/ || /^[[:space:]]*$/ {next}
        {d=tolower($1); if (!seen[d]++) print "  directive=" d}
    ' "$cfg"
done

section 'Mission 21: virtualization identification'
if available systemd-detect-virt; then run systemd-detect-virt; else printf 'systemd-detect-virt unavailable\n'; fi
run uname -a

section 'End of collection'
printf 'Review each result for privilege limits and target context. This collector does not establish findings or remediation success.\n'
