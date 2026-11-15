#!/usr/bin/env python3
"""Authenticate this account to localhost using a temporary, removed SSH key."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import uuid


def main():
    if os.name != 'posix' or not all(shutil.which(x) for x in ('ssh', 'ssh-keygen')):
        print('SKIPPED: requires Linux, ssh, and ssh-keygen')
        return 2
    ssh_dir = Path.home() / '.ssh'
    created_dir = not ssh_dir.exists()
    if ssh_dir.is_symlink():
        print('SKIPPED: .ssh is a symlink; existing configuration left untouched')
        return 2
    ssh_dir.mkdir(mode=0o700, exist_ok=True)
    auth = ssh_dir / 'authorized_keys'
    if ssh_dir.stat().st_uid != os.getuid() or auth.is_symlink():
        print('SKIPPED: SSH paths are not an ordinary directory/file owned by this account')
        return 2
    existed = auth.exists()
    if existed and (not auth.is_file() or auth.stat().st_uid != os.getuid()):
        print('SKIPPED: authorized_keys is not a regular file owned by this account')
        return 2
    original = auth.read_bytes() if existed else b''
    marker = 'securelab-temporary-' + uuid.uuid4().hex
    addition = b''
    rc = 2
    try:
        with tempfile.TemporaryDirectory(prefix='securelab-ssh-', dir=Path.cwd()) as temp:
            key = Path(temp) / 'identity'
            subprocess.run(['ssh-keygen', '-q', '-t', 'ed25519', '-N', '',
                            '-C', marker, '-f', str(key)], check=True)
            addition = (b'\n' if original and not original.endswith(b'\n') else b'')
            addition += key.with_suffix('.pub').read_bytes().rstrip(b'\n') + b'\n'
            if not existed:
                descriptor = os.open(auth, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
                os.close(descriptor)
            with auth.open('ab') as output:
                output.write(addition)
            print('Temporary key added for this account; testing authenticated localhost access.', flush=True)
            result = subprocess.run(['ssh', '-T', '-o', 'BatchMode=yes',
                '-o', 'IdentitiesOnly=yes', '-o', 'StrictHostKeyChecking=yes',
                '-o', 'ConnectTimeout=5', '-i', str(key), 'localhost',
                'printf "SECURELAB_SSH_LOGIN_OK\\n"; id'],
                stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT, text=True, timeout=12)
            print(result.stdout, end='')
            print('SSH exit status:', result.returncode)
            rc = result.returncode
    finally:
        if addition and auth.exists():
            current = auth.read_bytes()
            if addition in current:
                remaining = current.replace(addition, b'', 1)
                auth.write_bytes(remaining)
                if not existed and not remaining:
                    auth.unlink()
                print('Temporary authorized key removed; original entries preserved.')
            else:
                print('WARNING: temporary key record changed; inspect authorized_keys manually.')
                rc = 1
        if created_dir and ssh_dir.exists() and not any(ssh_dir.iterdir()):
            ssh_dir.rmdir()
    return rc


if __name__ == '__main__':
    raise SystemExit(main())
