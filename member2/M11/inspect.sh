#!/usr/bin/env bash
# Builds two variants and inspects metadata; executes neither program.
set -u
cd "$(dirname "$0")"
src=../M10/memory_overflow_demo.c
if ! command -v gcc >/dev/null 2>&1; then echo 'gcc unavailable'; exit 127; fi
echo '=== protected build ==='
gcc -Wall -Wextra -O0 -fstack-protector-strong -fPIE -pie "$src" -o memory_protected
protected_status=$?
printf 'Protected build exit code: %s\n' "$protected_status"
echo '=== reduced-compiler-protection build (inspection only; never execute) ==='
gcc -Wall -Wextra -O0 -fno-stack-protector -fno-pie -no-pie "$src" -o memory_reduced
reduced_status=$?
printf 'Reduced-protection build exit code: %s\n' "$reduced_status"
if [ "$protected_status" -ne 0 ] || [ "$reduced_status" -ne 0 ]; then exit 1; fi
if command -v checksec >/dev/null 2>&1; then
  echo '=== checksec protected ==='
  checksec --file=./memory_protected
  echo '=== checksec reduced ==='
  checksec --file=./memory_reduced
else
  echo 'checksec unavailable'
fi
echo '=== system ASLR setting (read-only, unchanged) ==='
if [ -r /proc/sys/kernel/randomize_va_space ]; then cat /proc/sys/kernel/randomize_va_space; else echo 'ASLR setting unavailable'; fi
if command -v readelf >/dev/null 2>&1; then
  echo '=== protected GNU_STACK program header ==='
  readelf -W -l ./memory_protected | grep GNU_STACK || true
  echo '=== reduced GNU_STACK program header ==='
  readelf -W -l ./memory_reduced | grep GNU_STACK || true
else
  echo 'readelf unavailable'
fi
