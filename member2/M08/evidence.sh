#!/usr/bin/env bash
# Safe ACL metadata demonstration on a new file owned by the current account.
# Does not switch identities or claim another user successfully read the file.
set -u
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(dirname "$SCRIPT_DIR")"
RUNS="$PACK_DIR/runs"
mkdir -p "$RUNS"
WORK="$(mktemp -d "$RUNS/M08.XXXXXX")" || exit 1
LOG="$WORK/evidence.txt"
exec > >(tee -a "$LOG") 2>&1
echo "Evidence directory: $WORK"
id
for tool in getfacl setfacl; do
  if command -v "$tool" >/dev/null 2>&1; then printf '%s available: %s\n' "$tool" "$(command -v "$tool")"; else printf '%s unavailable; request approved installation.\n' "$tool"; exit 0; fi
done
if ! getent passwd nobody >/dev/null; then
  echo 'nobody account unavailable; no named-user ACL demo performed.'
  exit 0
fi
FILE="$WORK/acl_demo.txt"
printf '%s\n' 'M08 harmless ACL test data' > "$FILE"
chmod 600 "$FILE"
echo '=== initial owner-only mode and ACL ==='
stat -c '%A %a %U:%G %n' "$FILE"
getfacl "$FILE"
echo '=== add read-only named ACL for nobody on this self-created file ==='
setfacl -m u:nobody:r-- "$FILE"
stat -c '%A %a %U:%G %n' "$FILE"
getfacl "$FILE"
echo 'The ACL entry and mask are demonstrated. No nobody/Bob read attempt was made.'
echo 'Actual cross-account access proof still requires the approved Alice/Bob experiment.'
