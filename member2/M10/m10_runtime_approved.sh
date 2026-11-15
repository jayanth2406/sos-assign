#!/usr/bin/env bash
# Optional unsafe runtime observation. Refuses to run without two explicit gates.
set -u
if [ "${SECURELAB_M10_RUNTIME_APPROVED:-}" != YES ] || [ "${SECURELAB_M10_ISOLATED_TARGET:-}" != YES ]; then
  echo 'Refusing to run: set SECURELAB_M10_RUNTIME_APPROVED=YES and SECURELAB_M10_ISOLATED_TARGET=YES only after instructor approval on a dedicated isolated target.' >&2
  exit 2
fi
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(dirname "$SCRIPT_DIR")"
RUNS="$PACK_DIR/runs"
mkdir -p "$RUNS"
WORK="$(mktemp -d "$RUNS/M10-runtime.XXXXXX")" || exit 1
LOG="$WORK/runtime.txt"
exec > >(tee -a "$LOG") 2>&1
echo "Approved isolated runtime evidence directory: $WORK"
echo "Started: $(date -Is)"
if ! command -v gcc >/dev/null 2>&1; then echo 'gcc unavailable'; exit 127; fi
gcc -Wall -Wextra -O0 -g "$SCRIPT_DIR/memory_overflow_demo.c" -o "$WORK/memory_overflow_demo" 2>&1
build_status=$?
printf 'Compiler exit code: %s\n' "$build_status"
if [ "$build_status" -ne 0 ]; then exit "$build_status"; fi
ulimit -c 0
set +e
echo '=== short input (expected to fit) ==='
"$WORK/memory_overflow_demo" short
short_status=$?
printf 'Short input exit code: %s\n' "$short_status"
echo '=== long fixed benign input (undefined behavior; outcome is not predictable) ==='
"$WORK/memory_overflow_demo" long
long_status=$?
printf 'Long input exit code: %s\n' "$long_status"
echo "Finished: $(date -Is)"
echo 'Record these actual outputs and statuses; neither outcome proves the unsafe copy is acceptable.'

