#!/usr/bin/env bash
# Aggregate evidence runner for approved Ubuntu via the authorized RustDesk session.
# Runs only user-owned exercises, read-only inspection, and the safe C companion.
set -u
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUNS="$SCRIPT_DIR/runs"
mkdir -p "$RUNS"
WORK="$(mktemp -d "$RUNS/aggregate.XXXXXX")" || exit 1
LOG="$WORK/run_missions.txt"
exec > >(tee -a "$LOG") 2>&1
echo "Aggregate evidence directory: $WORK"
echo "Started: $(date -Is)"
failures=0
run_step() {
  label="$1"
  shift
  echo
  echo "===== $label ====="
  "$@"
  status=$?
  echo "===== $label exit: $status ====="
  if [ "$status" -ne 0 ]; then failures=$((failures + 1)); fi
}
run_step 'M07 current-user file mode demo' bash "$SCRIPT_DIR/M07/evidence.sh"
run_step 'M08 current-user named ACL metadata demo' bash "$SCRIPT_DIR/M08/evidence.sh"
run_step 'M09 read-only privilege inspection' bash "$SCRIPT_DIR/M09/evidence.sh"
run_step 'M10 compile unsafe and checked samples only' bash "$SCRIPT_DIR/M10/compile.sh"
run_step 'M10 run bounds-checked short/long examples' bash "$SCRIPT_DIR/M10/run_safe_demo.sh"
run_step 'M11 paired build and metadata inspection only' bash "$SCRIPT_DIR/M11/inspect.sh"
run_step 'M12 user-owned directory and hash analogue' bash "$SCRIPT_DIR/M12/evidence.sh"
run_step 'M13 file integrity hash experiment' bash "$SCRIPT_DIR/M13/evidence.sh"
run_step 'M14 read-only log collection' bash "$SCRIPT_DIR/M14/evidence.sh"
echo
echo "Finished: $(date -Is)"
echo "Failures or unavailable required tools: $failures"
echo "No results are added to notes automatically; review the captured outputs and report limitations."
echo 'The opt-in unsafe M10 runtime script is deliberately excluded.'
exit "$(( failures > 0 ))"
