"""Install pinned MCP runtimes outside the checkout and render its local configuration."""
from __future__ import annotations
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess

from toolkit import ROOT, digest, ordinary, run


def runtime_packages(lock: dict):
    return [(name, package) for name, package in lock['packages'].items()
            if name.startswith('node_modules/') and not package.get('dev')]


def matches_runtime(root: Path, lock: dict) -> bool:
    for name, package in runtime_packages(lock):
        installed = root/name/'package.json'
        ordinary(installed)
        if not installed.is_file() or json.loads(installed.read_text(encoding='utf-8'))['version'] != package['version']:
            return False
    return True


def runtime_inventory(cache: Path) -> list[dict]:
    entries = []
    base = cache/'node_modules'
    ordinary(base)
    if not base.is_dir():
        raise ValueError('Missing dependency tree: '+str(base))
    for directory, dirs, names in os.walk(base, followlinks=False):
        for name in dirs:
            ordinary(Path(directory)/name)
        for name in names:
            path = Path(directory)/name
            ordinary(path)
            entries.append({'path': path.relative_to(base).as_posix(), 'bytes': path.stat().st_size, 'sha256': digest(path)})
    return sorted(entries, key=lambda entry: entry['path'])


def intact_runtime(cache: Path, lock_hash: str) -> bool:
    receipt = cache/'.installed-files.sha256.json'
    if not receipt.is_file():
        return False
    data = json.loads(receipt.read_text(encoding='utf-8'))
    return data.get('lockSha256') == lock_hash and data.get('files') == runtime_inventory(cache)


def record_runtime(name: str, source: Path) -> None:
    cache = Path(os.environ['LOCALAPPDATA'])/'BandaStation/agent-tools'/name
    data = {'lockSha256': digest(source/'package-lock.json'), 'files': runtime_inventory(cache)}
    (cache/'.installed-files.sha256.json').write_text(json.dumps(data, indent=2)+'\n', encoding='utf-8')


def install_runtime(name: str, source: Path, seed: Path | None, repair: bool) -> None:
    cache = Path(os.environ['LOCALAPPDATA'])/'BandaStation/agent-tools'/name
    ordinary(cache)
    if cache.resolve().is_relative_to(ROOT):
        raise ValueError('Dependencies must be outside the checkout')
    marker = cache/'.bandastation-agent-tools'
    if cache.exists() and not marker.is_file():
        raise ValueError('Refusing unowned dependency directory: '+str(cache))
    source_lock = source/'package-lock.json'
    lock = json.loads(source_lock.read_text())
    lock_hash = digest(source_lock)
    receipt = cache/'.installed-lock.sha256'
    ready = (not repair and receipt.is_file() and (cache/'package-lock.json').is_file()
             and receipt.read_text().strip() == lock_hash and digest(cache/'package-lock.json') == lock_hash
             and matches_runtime(cache, lock) and intact_runtime(cache, lock_hash))
    if not ready and seed:
        ordinary(seed)
        seed_lock = json.loads((seed/'package-lock.json').read_text(encoding='utf-8'))
        for package_name, package in runtime_packages(lock):
            if seed_lock['packages'].get(package_name, {}).get('version') != package['version']:
                raise ValueError('Seed lock differs: '+package_name)
        if not matches_runtime(seed, lock):
            raise ValueError('Installed seed does not match pinned runtime')
        # Validate every entry before copying; don't import unpinned nested packages.
        for directory, dirs, names in os.walk(seed/'node_modules', followlinks=False):
            for child in [*dirs, *names]:
                ordinary(Path(directory)/child)
    cache.mkdir(parents=True, exist_ok=True)
    marker.write_text('Managed BandaStation '+name+' MCP dependencies', encoding='utf-8')
    for document in ('package.json', 'package-lock.json'):
        shutil.copyfile(source/document, cache/document)
    if not ready:
        receipt.unlink(missing_ok=True)
        (cache/'.installed-files.sha256.json').unlink(missing_ok=True)
        if seed:
            for package_name, _ in runtime_packages(lock):
                target = cache/package_name
                ordinary(target)
                shutil.copytree(seed/package_name, target, dirs_exist_ok=True, ignore=shutil.ignore_patterns('node_modules'))
            print('Seeded pinned '+name+' dependencies from existing verified local runtime.')
        else:
            if not shutil.which('npm.cmd'):
                raise ValueError('npm is required for dependency installation')
            # Only fixed npm arguments enter cmd; the managed directory is passed as cwd.
            print(run(['cmd.exe', '/d', '/c', 'npm.cmd', 'ci', '--omit=dev', '--ignore-scripts',
                       '--no-audit', '--no-fund', '--prefer-offline'], cwd=cache).strip())
    else:
        print(name+' dependencies match lock; installation skipped.')
    if not matches_runtime(cache, lock):
        raise ValueError('Installed '+name+' runtime differs from its lock')
    if name == 'ripgrep':
        shutil.copyfile(source/'index.mjs', cache/'index.mjs')
    receipt.write_text(lock_hash+'\n', encoding='utf-8')


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repair', action='store_true')
    parser.add_argument('--config-only', action='store_true')
    parser.add_argument('--browser-seed', type=Path)
    parser.add_argument('--ripgrep-seed', type=Path)
    args = parser.parse_args()
    if os.name != 'nt' or not os.environ.get('LOCALAPPDATA'):
        raise ValueError('This setup requires Windows and LOCALAPPDATA')
    node = shutil.which('node.exe')
    if not node:
        raise ValueError('Node.js is required')
    config = ROOT/'.codex/config.toml'
    ordinary(config)
    header = '# Generated by tools/agents/setup-tools.ps1; source: .AGENTS/templates/codex.toml.'
    if config.exists() and not config.read_text(encoding='utf-8-sig').startswith(header):
        raise ValueError('Existing custom .codex/config.toml is preserved; merge it explicitly')
    print(run(['powershell.exe', '-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
               str(ROOT/'tools/agents/local-only.ps1'), '-Action', 'install'], cwd=ROOT).strip())
    if not args.config_only:
        install_runtime('browser', ROOT/'tools/agents', args.browser_seed, args.repair)
        install_runtime('ripgrep', ROOT/'tools/agents/ripgrep', args.ripgrep_seed, args.repair)
        for launcher in ('playwright-mcp.cjs', 'ripgrep-mcp.cjs'):
            print(run([node, str(ROOT/'tools/agents'/launcher), '--check'], cwd=ROOT).strip())
        record_runtime('browser', ROOT/'tools/agents')
        record_runtime('ripgrep', ROOT/'tools/agents/ripgrep')
    template = (ROOT/'.AGENTS/templates/codex.toml').read_text(encoding='utf-8-sig')
    path_token = lambda path: str(path).replace('\\', '/').replace('"', '\\"')
    rendered = template.replace('{{WORKSPACE}}', path_token(ROOT)).replace('{{NODE}}', path_token(node))
    if '{{' in rendered:
        raise ValueError('Unresolved MCP template token')
    config.parent.mkdir(parents=True, exist_ok=True)
    config.write_text(rendered, encoding='utf-8')
    print('PASS: checkout-local MCP config generated; global Codex config unchanged.')
    if args.config_only:
        print('SKIP: dependency installation and runtime checks (-ConfigOnly).')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        raise SystemExit(str(error)) from error
