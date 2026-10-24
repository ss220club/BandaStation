"""Offline checks of the shared instructions, source syntax and read-only inspector."""
from __future__ import annotations
import ast
import json
from pathlib import Path
import re
import subprocess
import sys
import tomllib

from toolkit import ROOT, SOURCE_PATHS, files


def inspect(*arguments: str, reject: bool = False) -> str:
    result = subprocess.run([sys.executable, '-B', str(ROOT/'tools/agents/inspect-repo.py'), *arguments],
                            capture_output=True, encoding='utf-8', errors='replace', timeout=60)
    if (result.returncode != 0) != reject:
        raise ValueError(result.stderr.strip() or 'Unexpected inspector result')
    return result.stdout


def main() -> None:
    links = 0
    for name in ('setup-tools.ps1', 'setup-tools.py', 'local-only.ps1', 'task.ps1', 'toolkit.py',
                 'playwright-mcp.cjs', 'ripgrep-mcp.cjs'):
        if not (ROOT/'tools/agents'/name).is_file():
            raise ValueError('Missing required agent tool: '+name)
    paths = [p for base in SOURCE_PATHS for p in files(ROOT/base)]
    for path in paths:
        content = path.read_text(encoding='utf-8-sig', errors='strict')
        if '\ufffd' in content or '\x00' in content:
            raise ValueError('Invalid text: '+str(path.relative_to(ROOT)))
        if any(line.rstrip() != line for line in content.splitlines()):
            raise ValueError('Trailing whitespace: '+str(path.relative_to(ROOT)))
        if path.suffix == '.py':
            ast.parse(content, filename=str(path))
        elif path.suffix == '.json':
            json.loads(content)
        elif path.suffix == '.toml':
            tomllib.loads(content)
        if path.suffix != '.md':
            continue
        for match in re.finditer(r'\[[^\]\r\n]+\]\(([^)\r\n]+)\)', content):
            url = match[1].strip('<>')
            if re.match(r'^(https?://|mailto:|#)', url):
                continue
            target = (path.parent/url.split('#', 1)[0]).resolve()
            if not target.is_relative_to(ROOT) or not target.exists():
                raise ValueError(f'Broken instruction link: {path.relative_to(ROOT)} -> {url}')
            links += 1
    for directory in (ROOT/'tools/agents', ROOT/'tools/agents/ripgrep'):
        package = json.loads((directory/'package.json').read_text())
        lock = json.loads((directory/'package-lock.json').read_text())
        if package['name'] != lock['name'] or package['dependencies'] != lock['packages']['']['dependencies']:
            raise ValueError('Package/lock root mismatch: '+str(directory))
    print(f'PASS: {len(paths)} UTF-8 files; {links} local instruction links; Python/JSON/TOML syntax; package locks')

    status = json.loads(inspect('status', '--limit', '3'))
    if Path(status['root']) != ROOT or len(status['sample']) > 3:
        raise ValueError('Inspector status root/bounds')
    includes = json.loads(inspect('includes', '--path', 'modular_bandastation/modular_bandastation.dme', '--limit', '3'))
    if not includes['entries'] or len(includes['entries']) > 3:
        raise ValueError('Inspector include bounds')
    sample = inspect('read', '--path', 'AGENTS.md', '--start', '1', '--count', '3')
    if len(sample.splitlines()) != 3 or not sample.startswith('1: '):
        raise ValueError('Inspector UTF-8/line bounds')
    inspect('read', '--path', '.git/config', reject=True)
    inspect('read', '--path', '../outside-repository.txt', reject=True)
    inspect('status', '--limit', '0', reject=True)
    print('PASS: read-only Git/include/UTF-8 inspector; output bounds and invalid paths/arguments')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        raise SystemExit(str(error)) from error
