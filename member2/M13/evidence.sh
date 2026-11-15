#!/usr/bin/env bash
# Harmless file-integrity demonstration isolated beside this script.
set -u
cd "$(dirname "$0")"
mkdir -p run
cd run
printf '%s\n' 'Approved configuration' > config.txt
sha256sum config.txt > config.sha256
echo '=== original digest ==='
cat config.sha256
echo '=== original verification ==='
sha256sum -c config.sha256
printf '%s\n' 'Unexpected change' >> config.txt
echo '=== changed digest ==='
sha256sum config.txt
echo '=== verification after modification (failure expected) ==='
sha256sum -c config.sha256 || true
