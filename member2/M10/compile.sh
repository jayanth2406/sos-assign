#!/usr/bin/env bash
# Compile unsafe and checked variants only. Neither binary is executed.
set -u
cd "$(dirname "$0")"
if ! command -v gcc >/dev/null 2>&1; then echo 'gcc unavailable'; exit 127; fi
set -o pipefail
gcc -Wall -Wextra -O0 -g memory_overflow_demo.c -o memory_overflow_demo 2>&1 | tee m10_compile.txt
unsafe_status=${PIPESTATUS[0]}
gcc -Wall -Wextra -O0 -g memory_copy_safe.c -o memory_copy_safe 2>&1 | tee -a m10_compile.txt
safe_status=${PIPESTATUS[0]}
printf 'Unsafe demo compiler exit code: %s\nSafe companion compiler exit code: %s\n' "$unsafe_status" "$safe_status"
if [ "$unsafe_status" -ne 0 ] || [ "$safe_status" -ne 0 ]; then exit 1; fi

