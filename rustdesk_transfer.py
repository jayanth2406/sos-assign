"""Transfer prepared lab files using the authenticated RustDesk MCP terminal."""
import base64
import io
import json
import os
from pathlib import Path
import sys
import textwrap
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parent
SESSION = (Path(os.environ['TEMP']) / 'securelab-rustdesk-session.txt').read_text().strip()

def call(name, **arguments):
    data = json.dumps({'jsonrpc': '2.0', 'id': 201, 'method': 'tools/call',
                       'params': {'name': name, 'arguments': arguments}}).encode()
    request = urllib.request.Request('http://127.0.0.1:59940/mcp', data=data,
                                    headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(request, timeout=35) as response:
        result = json.load(response)['result']
    if result.get('isError'):
        raise RuntimeError(result['content'][0]['text'])
    return result.get('structuredContent') or json.loads(result['content'][0]['text'])

def send(data):
    return call('terminal_input', session=SESSION, terminalId=1, data=data)

if __name__ == '__main__':
    if sys.argv[1] == 'read':
        output = call('terminal_output', session=SESSION, terminalId=1, limit=200000).get('output', '')
        if len(sys.argv) > 2:
            Path(sys.argv[2]).write_text(output, encoding='utf-8')
        print(output)
    elif sys.argv[1] == 'send':
        print(send(Path(sys.argv[2]).read_text(encoding='utf-8-sig') + '\n'))
    elif sys.argv[1] == 'transfer':
        buffer = io.BytesIO()
        paths = [ROOT / 'run_all.sh', ROOT / 'README.md']
        for folder in ['member1', 'member2', 'member3']:
            paths += [p for p in (ROOT / folder).rglob('*')
                      if p.is_file() and '__pycache__' not in p.parts and 'bin' not in p.parts]
        with zipfile.ZipFile(buffer, 'w', zipfile.ZIP_DEFLATED) as archive:
            for path in paths:
                archive.writestr(str(path.relative_to(ROOT)).replace('\\', '/'),
                                 path.read_text(encoding='utf-8').replace('\r\n', '\n'))
        encoded = '\n'.join(textwrap.wrap(base64.b64encode(buffer.getvalue()).decode(), 100))
        script = "stty -echo\npython3 - <<'SECURELAB_TRANSFER_PY'\n"
        script += "import base64,io,pathlib,zipfile,datetime\n"
        script += "dest=pathlib.Path.home()/'Downloads'/'sos'/('securelab-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S'))\n"
        script += "dest.mkdir(parents=True,exist_ok=False)\n"
        script += "data=base64.b64decode('''" + encoded + "''')\n"
        script += "z=zipfile.ZipFile(io.BytesIO(data)); z.extractall(dest)\n"
        script += "print('SECURELAB_TRANSFER_OK',str(dest),len(z.namelist()))\n"
        script += "(pathlib.Path.home()/'Downloads'/'sos'/'.securelab-current').write_text(str(dest))\n"
        script += "SECURELAB_TRANSFER_PY\nstty echo\n"
        print(send(script))
