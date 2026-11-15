#!/usr/bin/env bash
# Read-only event collection. Does not enable SSH or alter services.
set +e
echo '=== time ==='
date -Is
echo '=== identity ==='
whoami
echo '=== last 30 journal entries ==='
journalctl -n 30 --no-pager 2>&1
echo '=== recent journal entries ==='
journalctl --since '15 minutes ago' --no-pager 2>&1
echo '=== SSH service status (read-only) ==='
systemctl status ssh --no-pager 2>/dev/null || true
echo '=== SSH journal entries (read-only) ==='
journalctl -u ssh --no-pager 2>/dev/null | tail -30
echo '=== recent login records ==='
last | head -10
