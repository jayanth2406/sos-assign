#!/usr/bin/env bash
# User-owned analogue of M12's directory boundary plus an integrity check.
# Creates files only in this pack's unique runs/M12.* directory.
set -u
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(dirname "$SCRIPT_DIR")"
RUNS="$PACK_DIR/runs"
mkdir -p "$RUNS"
WORK="$(mktemp -d "$RUNS/M12.XXXXXX")" || exit 1
LOG="$WORK/evidence.txt"
exec > >(tee -a "$LOG") 2>&1
echo "Evidence directory: $WORK"
id
BASE="$WORK/securelab"
mkdir -m 755 "$BASE"
mkdir -m 755 "$BASE/public"
mkdir -m 750 "$BASE/employees" "$BASE/secrets"
printf '%s\n' 'Approved lab incident note (harmless demo)' > "$BASE/secrets/incident.txt"
chmod 640 "$BASE/secrets/incident.txt"
echo '=== user-owned analogue of M12 directory/file modes ==='
stat -c '%A %a %U:%G %n' "$BASE" "$BASE/public" "$BASE/employees" "$BASE/secrets" "$BASE/secrets/incident.txt"
echo '=== current-owner traversal and read check ==='
if test -x "$BASE" && test -x "$BASE/secrets" && test -r "$BASE/secrets/incident.txt"; then
  cat "$BASE/secrets/incident.txt"
  echo 'Current owner can traverse and read.'
else
  echo 'Current owner access check failed.'
fi
echo '=== baseline hash, verify, modify, verify again ==='
sha256sum "$BASE/secrets/incident.txt" > "$WORK/incident.sha256"
cat "$WORK/incident.sha256"
sha256sum -c "$WORK/incident.sha256"
printf '%s\n' 'Harmless modification' >> "$BASE/secrets/incident.txt"
sha256sum "$BASE/secrets/incident.txt"
set +e
sha256sum -c "$WORK/incident.sha256"
check_status=$?
set -u
printf 'Post-modification verification exit code: %s (nonzero is expected)\n' "$check_status"
echo 'This is a current-user analogue only; it does not prove Alice/Bob access or the required /opt setup.'
