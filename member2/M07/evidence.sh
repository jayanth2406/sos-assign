#!/usr/bin/env bash
# Safe mode-bit demonstration on a new file owned by the current account.
# This does not impersonate Alice or Bob and cannot prove another user's access.
set -u
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(dirname "$SCRIPT_DIR")"
RUNS="$PACK_DIR/runs"
mkdir -p "$RUNS"
WORK="$(mktemp -d "$RUNS/M07.XXXXXX")" || exit 1
LOG="$WORK/evidence.txt"
exec > >(tee -a "$LOG") 2>&1
echo "Evidence directory: $WORK"
echo '=== current account and Alice/Bob preflight ==='
id
for user in alice bob; do
  if getent passwd "$user" >/dev/null; then
    printf '%s exists; confirm instructor designation before any cross-account test.\n' "$user"
  else
    printf '%s absent; do not create without approval.\n' "$user"
  fi
done
FILE="$WORK/current_user_secret.txt"
printf '%s\n' 'M07 harmless test data' > "$FILE"
chmod 644 "$FILE"
echo '=== current-user-owned file at mode 644 ==='
stat -c '%A %a %U:%G %n' "$FILE"
cat "$FILE"
chmod 600 "$FILE"
echo '=== same file at mode 600 ==='
stat -c '%A %a %U:%G %n' "$FILE"
cat "$FILE"
echo 'The current owner reads both states. No Alice/Bob or second-user access is claimed.'
echo 'Exact Alice/Bob trial still requires approved test accounts and target described in notes.md.'
