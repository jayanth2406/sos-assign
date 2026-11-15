"""Validate and package the scoped assignment without connection credentials."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parent


def main():
    checks = []
    shell = Path('C:/Program Files/Git/bin/bash.exe')
    scripts = [ROOT / 'run_all.sh']
    for folder in ('member1', 'member2', 'member3'):
        scripts.extend((ROOT / folder).rglob('*.sh'))
    for script in scripts:
        result = subprocess.run([str(shell), '-n', str(script)], capture_output=True, text=True)
        if result.returncode:
            raise RuntimeError(f'{script.relative_to(ROOT)}: {result.stderr}')
        checks.append(f'{script.relative_to(ROOT)}: shell syntax passed')
    for script in [ROOT / 'package_check.py', ROOT / 'rustdesk_transfer.py',
                   *(ROOT / 'member3').glob('*.py')]:
        compile(script.read_text(encoding='utf-8'), str(script), 'exec')
        checks.append(f'{script.relative_to(ROOT)}: Python syntax passed')
    missing = []
    for document in [ROOT / 'README.md', *(ROOT / 'final').glob('*.md')]:
        for target in re.findall(r'\]\(([^)]+)\)', document.read_text(encoding='utf-8')):
            if '://' not in target and not target.startswith('#'):
                if not (document.parent / target.split('#')[0]).exists():
                    missing.append((str(document.relative_to(ROOT)), target))
    if missing:
        raise RuntimeError(f'Missing document links: {missing}')
    checks.append('README and final report/audit links passed')
    allowed = [ROOT / 'README.md', ROOT / 'run_all.sh', ROOT / 'package_check.py',
               ROOT / 'rustdesk_transfer.py', *(ROOT / 'final').glob('*.md')]
    for folder in ('member1', 'member2', 'member3', 'doc', 'evidence'):
        allowed.extend(p for p in (ROOT / folder).rglob('*')
                       if p.is_file() and '__pycache__' not in p.parts)
    raw = (ROOT / 'rust-keys.txt').read_text(encoding='utf-8')
    secret = re.search(r'(?im)^password\s*[:=]\s*(.+)$', raw)[1].strip().encode()
    for path in allowed:
        if secret in path.read_bytes():
            raise RuntimeError(f'Credential content detected in {path.relative_to(ROOT)}')
    checks.append('Credential exclusion and content checks passed')
    (ROOT / 'evidence/local_checks.txt').write_text('\n'.join(checks) + '\n', encoding='utf-8')
    destination = ROOT / 'final/securelab-prepared.zip'
    with zipfile.ZipFile(destination, 'w', zipfile.ZIP_DEFLATED) as archive:
        for path in allowed:
            archive.write(path, path.relative_to(ROOT))
    with zipfile.ZipFile(destination) as archive:
        assert archive.testzip() is None
        assert all('rust-keys' not in name for name in archive.namelist())
        count = len(archive.namelist())
    digest = hashlib.sha256(destination.read_bytes()).hexdigest()
    destination.with_suffix('.sha256').write_text(f'{digest}  {destination.name}\n')
    print(json.dumps({'files': count, 'archive': str(destination), 'sha256': digest,
                      'checks': len(checks)}, indent=2))


if __name__ == '__main__':
    main()
