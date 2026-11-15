#!/usr/bin/env bash
# Run only on the authorized Linux target, through RustDesk MCP.
set -u
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
mkdir -p "$root/evidence"
cd "$root"
exec > >(tee "$root/evidence/combined_run.txt") 2>&1
failures=0
run_step() {
    printf '\n===== %s =====\n' "$1"
    shift
    "$@"
    rc=$?
    printf '\nStep exit status: %s\n' "$rc"
    if [ "$rc" -ne 0 ]; then failures=$((failures + 1)); fi
}
{
    date -Is
    id
    uname -a
    cat /etc/os-release
    run_step 'Missions 1-6' bash member1/run_missions.sh
    run_step 'Missions 7-14 (user-owned analogues where needed)' bash member2/run_missions.sh
    run_step 'Missions 15-21 inspection' bash member3/collect.sh
    run_step 'M15 supplementary resource-limit demonstration' python3 member3/sandbox_demo.py
    printf '\nRunner steps with failures: %s\n' "$failures"
    printf 'Review all logs before marking missions verified. M22 requires separate instructor resources.\n'
}
exit "$((failures > 0))"
