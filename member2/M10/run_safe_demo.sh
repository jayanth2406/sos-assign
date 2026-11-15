#!/usr/bin/env bash
# Runs only the bounds-checked companion, with fixed short and long selections.
set -u
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(dirname "$SCRIPT_DIR")"
RUNS="$PACK_DIR/runs"
mkdir -p "$RUNS"
WORK="$(mktemp -d "$RUNS/M10-safe.XXXXXX")" || exit 1
LOG="$WORK/safe_demo.txt"
exec > >(tee -a "$LOG") 2>&1
echo "Safe companion evidence directory: $WORK"
if ! command -v gcc >/dev/null 2>&1; then echo 'gcc unavailable'; exit 127; fi
gcc -Wall -Wextra -O0 -g "$SCRIPT_DIR/memory_copy_safe.c" -o "$WORK/memory_copy_safe" 2>&1
build_status=$?
printf 'Compiler exit code: %s\n' "$build_status"
if [ "$build_status" -ne 0 ]; then exit "$build_status"; fi
set +e
echo '=== bounds-checked short input ==='
"$WORK/memory_copy_safe" short
short_status=$?
printf 'Short input exit code: %s\n' "$short_status"
echo '=== bounds-checked long input ==='
"$WORK/memory_copy_safe" long
long_status=$?
printf 'Long input exit code: %s (rejection is expected)\n' "$long_status"
if [ "$short_status" -ne 0 ] || [ "$long_status" -ne 1 ]; then exit 1; fi
