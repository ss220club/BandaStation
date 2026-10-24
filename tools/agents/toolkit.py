"""Export, verify and install shared agent sources without local task or machine data."""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import stat
import subprocess

ROOT = Path(__file__).resolve().parents[2]
SOURCE_PATHS = [
    'AGENTS.md', '.AGENTS/README.md', '.AGENTS/PROJECT_CONTEXT.md', '.AGENTS/WORKFLOW_RULES.md',
    '.AGENTS/TASK_STATE.md', '.AGENTS/TOOLS.md', '.AGENTS/PORTING.md', '.AGENTS/KNOWN_ISSUES.md',
    '.AGENTS/templates', '.AGENTS/skills/bandastation-workflow', 'tools/agents',
]
RUNTIME_PATHS = [':(icase).codex', ':(icase)task_state', ':(icase).AGENTS/local']

def digest(path: Path) -> str:
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()

def ordinary(path: Path) -> None:
    current = path.absolute()
    for candidate in [current, *current.parents]:
        try:
            attributes = getattr(candidate.lstat(), 'st_file_attributes', 0)
        except FileNotFoundError:
            continue
        if candidate.is_symlink() or attributes & stat.FILE_ATTRIBUTE_REPARSE_POINT:
            raise ValueError(f'Redirected bundle path: {candidate}')

def files(base: Path):
    ordinary(base)
    if not base.exists():
        raise ValueError(f'Missing bundle source: {base}')
    if base.is_file():
        yield base
    else:
        for directory, dirs, names in os.walk(base, followlinks=False):
            for name in dirs:
                ordinary(Path(directory)/name)
                if name in ('node_modules', '__pycache__', '.git'):
                    raise ValueError(f'Unexpected generated directory: {Path(directory)/name}')
            for name in sorted(names):
                candidate = Path(directory)/name
                ordinary(candidate)
                yield candidate

def relative_file(bundle: Path, relative: str) -> Path:
    name = PurePosixPath(relative)
    if not name.parts or name.as_posix() != relative or name.is_absolute() or '..' in name.parts or '\\' in relative or ':' in relative:
        raise ValueError(f'Unsafe manifest path: {relative}')
    target = bundle.joinpath(*name.parts)
    ordinary(target)
    if not target.resolve().is_relative_to(bundle.resolve()):
        raise ValueError(f'Manifest path escapes bundle: {relative}')
    return target

def verify(bundle: Path) -> dict:
    ordinary(bundle)
    data = json.loads((bundle/'manifest.json').read_text(encoding='utf-8-sig'))
    if data.get('format') != 'bandastation-agent-toolkit-v1':
        raise ValueError('Unknown bundle format')
    seen = set()
    for entry in data['files']:
        relative = entry['path']
        if relative.casefold() in seen:
            raise ValueError('Duplicate manifest path: '+relative)
        seen.add(relative.casefold())
        candidate = relative_file(bundle, relative)
        if not candidate.is_file() or candidate.stat().st_size != entry['bytes'] or digest(candidate) != entry['sha256']:
            raise ValueError('Bundle checksum mismatch: '+relative)
    actual = {p.relative_to(bundle).as_posix().casefold() for p in files(bundle) if p != bundle/'manifest.json'}
    if actual != seen:
        raise ValueError('Bundle contains missing or unlisted files')
    print(f'PASS: {len(seen)} manifest files verified with SHA256')
    return data

def copy(source: Path, destination: Path) -> None:
    ordinary(source)
    ordinary(destination)
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)

def export(destination: Path) -> None:
    ordinary(destination)
    for name in ('setup-tools.ps1', 'setup-tools.py', 'local-only.ps1', 'task.ps1', 'toolkit.py',
                 'playwright-mcp.cjs', 'ripgrep-mcp.cjs'):
        if not (ROOT/'tools/agents'/name).is_file():
            raise ValueError('Missing required agent tool: '+name)
    if destination.exists():
        raise ValueError('Export never overwrites an existing bundle; choose a new destination/version')
    if destination.resolve().is_relative_to(ROOT):
        raise ValueError('Store the bundle outside the source checkout')
    destination.mkdir(parents=True)
    for name in SOURCE_PATHS:
        for item in files(ROOT/name):
            copy(item, destination/'payload'/item.relative_to(ROOT))
    installer = """param([Parameter(Mandatory=$true)][string]$Repository,[switch]$InstallDependencies)
$ErrorActionPreference='Stop'
$arguments=@('-3','-B',(Join-Path $PSScriptRoot 'payload/tools/agents/toolkit.py'),'install','--bundle',$PSScriptRoot,'--destination',$Repository)
if($InstallDependencies){$arguments+='--install-dependencies'}
& py @arguments
if($LASTEXITCODE -ne 0){throw 'Toolkit installation failed.'}
"""
    (destination/'Install.ps1').write_text(installer, encoding='utf-8')
    (destination/'README.md').write_text("""# Агентский набор BandaStation

Проверка: `py -3 -B payload/tools/agents/toolkit.py verify --bundle .`
Установка: `./Install.ps1 -Repository '<BandaStation checkout>'`.
`-InstallDependencies` устанавливает закреплённые MCP зависимости, иначе запускается ConfigOnly.

Payload содержит общие инструкции, skill, шаблоны, утилиты и locks. Истории задач,
машинного конфига, зависимостей и Git metadata здесь нет. Manifest проверяет SHA256.
Существующие различающиеся файлы не перезаписываются. Новые общие исходники видны
в Git; установщик их не индексирует и не коммитит. Подробности: payload/.AGENTS/PORTING.md.
""", encoding='utf-8')
    entries = [{'path': p.relative_to(destination).as_posix(), 'bytes': p.stat().st_size, 'sha256': digest(p)} for p in files(destination)]
    data = {'format': 'bandastation-agent-toolkit-v1', 'files': sorted(entries, key=lambda e:e['path'])}
    (destination/'manifest.json').write_text(json.dumps(data, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    verify(destination)
    print('Bundle exported: '+str(destination))

def run(command: list[str], cwd: Path | None = None) -> str:
    result = subprocess.run(command, cwd=cwd, encoding='utf-8', errors='replace', capture_output=True, timeout=300)
    if result.returncode:
        raise ValueError(result.stderr.strip() or result.stdout.strip() or f'Command failed: {command[0]}')
    return result.stdout

def install(bundle: Path, destination: Path, dependencies: bool) -> None:
    data = verify(bundle)
    ordinary(destination)
    if not (destination/'tgstation.dme').is_file() or not (destination/'modular_bandastation/modular_bandastation.dme').is_file():
        raise ValueError('Adapt the project overlay first: this installer requires a BandaStation layout')
    actual_root = Path(run(['git', '-C', str(destination), 'rev-parse', '--show-toplevel']).strip()).resolve()
    if destination.resolve() != actual_root:
        raise ValueError('Destination must be the Git checkout root')
    if run(['git', '-C', str(destination), 'ls-files', '--', *RUNTIME_PATHS]).strip():
        raise ValueError('Destination runtime paths overlap tracked/staged files; installation stopped before copying')
    hooks = subprocess.run(['git', '-C', str(destination), 'config', '--get', 'core.hooksPath'], capture_output=True, text=True)
    if hooks.stdout.strip():
        raise ValueError('Custom core.hooksPath is preserved; integrate its runtime guard explicitly')
    hook_name = run(['git', '-C', str(destination), 'rev-parse', '--git-path', 'hooks/pre-commit']).strip()
    hook = Path(hook_name) if Path(hook_name).is_absolute() else destination/hook_name
    ordinary(hook)
    if hook.exists() and '# Managed BandaStation agent runtime guard v2.' not in hook.read_text(encoding='utf-8-sig'):
        raise ValueError('Custom pre-commit hook is preserved; installation stopped before copying')
    config = destination/'.codex/config.toml'
    ordinary(config)
    if config.exists() and not config.read_text(encoding='utf-8-sig').startswith('# Generated by tools/agents/setup-tools.ps1;'):
        raise ValueError('Custom .codex/config.toml is preserved')
    selected = []
    for entry in data['files']:
        name = PurePosixPath(entry['path'])
        if name.parts[0] == 'payload':
            relative = Path(*name.parts[1:])
            value = relative.as_posix()
            if not any(value == base or value.startswith(base+'/') for base in SOURCE_PATHS):
                raise ValueError('Unexpected payload path: '+str(relative))
        else:
            continue
        target = destination/relative
        ordinary(target)
        if target.exists() and (not target.is_file() or digest(target) != entry['sha256']):
            raise ValueError('Existing local file differs; installation never overwrites it: '+str(target))
        selected.append((relative_file(bundle, entry['path']), target))
    for source, target in selected:
        if not target.exists():
            copy(source, target)
    args = ['powershell.exe', '-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(destination/'tools/agents/setup-tools.ps1')]
    if not dependencies:
        args.append('-ConfigOnly')
    print(run(args, cwd=destination).strip())
    print(f'PASS: installed {len(selected)} shared source files; index/history unchanged; custom files preserved')

def main() -> None:
    parser=argparse.ArgumentParser(description=__doc__)
    sub=parser.add_subparsers(dest='command', required=True)
    export_parser=sub.add_parser('export'); export_parser.add_argument('--destination', type=Path, required=True)
    verify_parser=sub.add_parser('verify'); verify_parser.add_argument('--bundle', type=Path, required=True)
    install_parser=sub.add_parser('install'); install_parser.add_argument('--bundle', type=Path, required=True); install_parser.add_argument('--destination', type=Path, required=True)
    install_parser.add_argument('--install-dependencies', action='store_true')
    args=parser.parse_args()
    if args.command == 'export': export(args.destination.absolute())
    elif args.command == 'verify': verify(args.bundle.absolute())
    else: install(args.bundle.absolute(), args.destination.absolute(), args.install_dependencies)

if __name__ == '__main__':
    try: main()
    except (OSError, ValueError, subprocess.SubprocessError) as error: raise SystemExit(str(error)) from error
