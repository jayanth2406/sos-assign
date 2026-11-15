#!/usr/bin/env bash
# Read-only inspection: no privilege or binary changes.
set +e
echo '=== identity ==='; id
echo '=== sudo policy (non-interactive) ==='; sudo -n -l 2>&1
echo '=== current shell capabilities ==='
if command -v capsh >/dev/null 2>&1; then capsh --print | head -40; else echo 'capsh unavailable'; fi
echo '=== existing /usr/bin file capabilities ==='
if command -v getcap >/dev/null 2>&1; then getcap -r /usr/bin 2>/dev/null | head -20; else echo 'getcap unavailable'; fi
