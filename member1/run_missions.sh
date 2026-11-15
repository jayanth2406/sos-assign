#!/usr/bin/env bash
# Run Person 1's Missions 1-6 on an approved Ubuntu lab machine.
# This runner records real command output; it contains no example/fabricated results.
set -euo pipefail

member_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd -- "$member_dir/.." && pwd)
src="$member_dir/src"
bin="$member_dir/bin"
evidence="$member_dir/evidence"
mkdir -p "$bin" "$evidence"
cd "$src"

run_logged() {
    local log=$1
    shift
    {
        printf '\n$'
        printf ' %q' "$@"
        printf '\n'
        "$@"
    } 2>&1 | tee -a "$evidence/$log"
}

printf 'SECURELAB Person 1 evidence run\n' | tee "$evidence/run_metadata.txt"
printf 'Timestamp (UTC): %s\nHost: %s\nUser: %s\n' \
    "$(date -u +%FT%TZ)" "$(hostname)" "$(id -un)" | tee -a "$evidence/run_metadata.txt"
printf 'Repository path: %s\n' "$repo_dir" | tee -a "$evidence/run_metadata.txt"
printf 'This run records this machine\x27s output; no values are pre-filled.\n' \
    | tee -a "$evidence/run_metadata.txt"

# Mission 1: account/process credentials.
gcc -Wall -Wextra -g identity.c -o "$bin/identity"
run_logged m01_identity.txt id
run_logged m01_identity.txt groups
run_logged m01_identity.txt "$bin/identity"

# Mission 2: create the file and retain the complete system-call trace.
gcc -Wall -Wextra -g syscall_demo.c -o "$bin/syscall_demo"
run_logged m02_syscall.txt "$bin/syscall_demo"
run_logged m02_syscall.txt cat hello.txt
if command -v strace >/dev/null 2>&1; then
    {
        printf '\n$ strace -o %q %q\n' "$evidence/m02_trace.txt" "$bin/syscall_demo"
        if strace -o "$evidence/m02_trace.txt" "$bin/syscall_demo"; then
            printf '\nRelevant calls from the captured trace:\n'
            grep -E 'openat|write\(|close\(' "$evidence/m02_trace.txt" | tail -20 || true
        else
            trace_status=$?
            printf '\nstrace could not collect a complete trace (exit %s); preserve this environment limitation.\n' \
                "$trace_status"
        fi
    } 2>&1 | tee -a "$evidence/m02_syscall.txt"
else
    printf '\nstrace is unavailable; no trace was produced. Ask the lab administrator before installing it.\n' \
        | tee -a "$evidence/m02_syscall.txt"
fi

# Mission 3: inspect a harmless process owned by this user and clean it up.
chmod +x "$src/proc_inspector.sh"
sleep 120 &
test_pid=$!
cleanup() { kill "$test_pid" 2>/dev/null || true; wait "$test_pid" 2>/dev/null || true; }
trap cleanup EXIT INT TERM
{
    printf '$ sleep 120 &\nPID=%s\n' "$test_pid"
    printf '$ ps -p %q -o pid,ppid,uid,cmd\n' "$test_pid"
    ps -p "$test_pid" -o pid,ppid,uid,cmd
    printf '\n$ %q %q\n' "$src/proc_inspector.sh" "$test_pid"
    "$src/proc_inspector.sh" "$test_pid"
    printf '\n$ ls -l %q/fd\n' "/proc/$test_pid"
    ls -l "/proc/$test_pid/fd"
} 2>&1 | tee "$evidence/m03_process.txt"
cleanup
trap - EXIT INT TERM

# Mission 4: inspect only this runner's own demonstration process.
gcc -Wall -Wextra -g address_space.c -o "$bin/address_space"
"$bin/address_space" > "$evidence/m04_program.txt" 2>&1 &
address_pid=$!
cleanup_address() {
    if [[ -n ${address_pid:-} ]]; then
        kill "$address_pid" 2>/dev/null || true
        wait "$address_pid" 2>/dev/null || true
    fi
}
trap cleanup_address EXIT INT TERM
{
    printf '$ %q (started as PID %s)\n' "$bin/address_space" "$address_pid"
    sleep 1
    cat "$evidence/m04_program.txt"
    printf '\n$ cat /proc/%s/maps\n' "$address_pid"
    cat "/proc/$address_pid/maps" | tee "$evidence/m04_maps.txt"
} 2>&1 | tee "$evidence/m04_address_space.txt"
printf '\n$ wait %s\n' "$address_pid" | tee -a "$evidence/m04_address_space.txt"
if wait "$address_pid"; then
    address_status=0
else
    address_status=$?
fi
printf 'address_space exit status: %s\n' "$address_status" \
    | tee -a "$evidence/m04_address_space.txt"
address_pid=
trap - EXIT INT TERM
if ((address_status != 0)); then
    exit "$address_status"
fi

# Mission 5: capture three real unsynchronized runs and two protected runs.
gcc -Wall -Wextra -O0 -pthread race_demo.c -o "$bin/race_demo"
gcc -Wall -Wextra -O0 -pthread race_fixed.c -o "$bin/race_fixed"
for run in 1 2 3; do
    run_logged m05_race_before.txt "$bin/race_demo"
done
for run in 1 2; do
    run_logged m05_race_after.txt "$bin/race_fixed"
done

# Mission 6: the handout did not include the instructor's shared-memory design.
# This separately labeled team-authored POSIX example provides a runnable comparison.
gcc -Wall -Wextra -g pipe_ipc.c -o "$bin/pipe_ipc"
gcc -Wall -Wextra -g -pthread shared_memory_ipc.c -o "$bin/shared_memory_ipc" -lrt
run_logged m06_pipe.txt "$bin/pipe_ipc"
run_logged m06_shared_memory.txt "$bin/shared_memory_ipc"
printf 'The shared-memory program is a team-authored POSIX shm_open/mmap demonstration; no instructor implementation was included in the supplied PDFs. See notes/Missions_1-6_answers.md for the comparison.\n' \
    | tee "$evidence/m06_shared_memory_status.txt"

printf '\nEvidence files created under %s\n' "$evidence"
