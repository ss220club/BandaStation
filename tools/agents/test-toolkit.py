"""Exercise portable export/install and local Git guards only in disposable repositories."""
from __future__ import annotations
import json
import importlib.util
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile
import tomllib

from toolkit import ROOT, digest, ordinary, RUNTIME_PATHS


def run(*command: str, reject: str | None = None, cwd: Path | None = None) -> str:
    result = subprocess.run(command, cwd=cwd, capture_output=True, encoding='utf-8', errors='replace', timeout=300,
                            env={**os.environ, 'PYTHONIOENCODING': 'utf-8', 'PYTHONDONTWRITEBYTECODE': '1'})
    output = result.stdout+result.stderr
    if reject is None and result.returncode:
        raise ValueError(output)
    if reject is not None and (not result.returncode or reject not in output):
        raise ValueError('Expected refusal '+reject+'; got: '+output)
    return output


def repository(stage: Path, name: str) -> Path:
    root = stage/name
    (root/'modular_bandastation').mkdir(parents=True)
    (root/'tgstation.dme').write_text('#include "modular_bandastation/modular_bandastation.dme"\n', encoding='utf-8')
    (root/'modular_bandastation/modular_bandastation.dme').write_text('// test-only fixture\n', encoding='utf-8')
    run('git', 'init', '-q', str(root))
    run('git', '-C', str(root), 'add', '--', 'tgstation.dme', 'modular_bandastation/modular_bandastation.dme')
    run('git', '-C', str(root), '-c', 'user.name=Toolkit verification', '-c', 'user.email=toolkit-fixture@localhost',
        '-c', 'commit.gpgSign=false', 'commit', '-q', '-m', 'Disposable fixture baseline')
    return root


def install(bundle: Path, destination: Path, *flags: str, reject: str | None = None) -> str:
    return run('powershell.exe', '-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(bundle/'Install.ps1'),
               '-Repository', str(destination), *flags, reject=reject)


def main() -> None:
    stage = Path(tempfile.mkdtemp(prefix='bandastation-agent-test-')).absolute()
    temporary_root = Path(tempfile.gettempdir()).resolve()
    global_config = Path.home()/'.codex/config.toml'
    global_hash = digest(global_config) if global_config.exists() else None
    toolkit = ROOT/'tools/agents/toolkit.py'
    try:
        specification = importlib.util.spec_from_file_location('setup_tools', ROOT/'tools/agents/setup-tools.py')
        setup = importlib.util.module_from_spec(specification)
        specification.loader.exec_module(setup)
        runtime = stage/'runtime-fixture'
        (runtime/'node_modules/example').mkdir(parents=True)
        example = runtime/'node_modules/example/index.js'
        example.write_text('// original\n', encoding='utf-8')
        receipt = {'lockSha256': 'fixture-lock', 'files': setup.runtime_inventory(runtime)}
        (runtime/'.installed-files.sha256.json').write_text(json.dumps(receipt), encoding='utf-8')
        if not setup.intact_runtime(runtime, 'fixture-lock'):
            raise ValueError('Fresh runtime inventory rejected')
        example.write_text('// modified\n', encoding='utf-8')
        if setup.intact_runtime(runtime, 'fixture-lock'):
            raise ValueError('Modified runtime file accepted')
        example.unlink()
        if setup.intact_runtime(runtime, 'fixture-lock'):
            raise ValueError('Deleted runtime file accepted')
        saved_local_data = os.environ['LOCALAPPDATA']
        foreign = stage/'fake-local/BandaStation/agent-tools/browser'
        foreign.mkdir(parents=True)
        (foreign/'keep.txt').write_text('foreign sentinel')
        try:
            os.environ['LOCALAPPDATA'] = str(stage/'fake-local')
            try:
                setup.install_runtime('browser', ROOT/'tools/agents', None, False)
            except ValueError as error:
                if 'unowned dependency directory' not in str(error):
                    raise
            else:
                raise ValueError('Foreign dependency directory accepted')
            if (foreign/'keep.txt').read_text() != 'foreign sentinel' or len(list(foreign.iterdir())) != 1:
                raise ValueError('Foreign dependency directory changed')
        finally:
            os.environ['LOCALAPPDATA'] = saved_local_data
        print('PASS: SHA256 runtime inventory rejects modified/deleted files; foreign dependency cache preserved')
        bundle = stage/'bundle'
        run(sys.executable, '-B', str(toolkit), 'export', '--destination', str(bundle))
        run(sys.executable, '-B', str(toolkit), 'verify', '--bundle', str(bundle))
        original = (bundle/'payload/AGENTS.md').read_bytes()
        (bundle/'payload/AGENTS.md').write_bytes(original+b'\nchanged\n')
        run(sys.executable, '-B', str(toolkit), 'verify', '--bundle', str(bundle), reject='Bundle checksum mismatch')
        (bundle/'payload/AGENTS.md').write_bytes(original)
        (bundle/'unlisted.txt').write_text('test')
        run(sys.executable, '-B', str(toolkit), 'verify', '--bundle', str(bundle), reject='unlisted files')
        (bundle/'unlisted.txt').unlink()
        run(sys.executable, '-B', str(toolkit), 'export', '--destination', str(bundle), reject='never overwrites')
        print('PASS: export/manifest SHA256; tamper and unlisted-file detection; no overwrite')

        root = repository(stage, 'checkout Кириллица с пробелом')
        baseline_head = run('git', '-C', str(root), 'rev-parse', 'HEAD')
        baseline_index = digest(root/'.git/index')
        product_hashes = {p: digest(root/p) for p in ('tgstation.dme', 'modular_bandastation/modular_bandastation.dme')}
        install(bundle, root)
        manifest = json.loads((bundle/'manifest.json').read_text(encoding='utf-8'))
        for entry in manifest['files']:
            if entry['path'].startswith('payload/'):
                relative = entry['path'].removeprefix('payload/')
                if digest(root/relative) != entry['sha256']:
                    raise ValueError('Installed bytes differ: '+relative)
        if digest(root/'.git/index') != baseline_index or run('git', '-C', str(root), 'rev-parse', 'HEAD') != baseline_head:
            raise ValueError('Installer changed index/history')
        visible = run('git', '-C', str(root), 'ls-files', '--others', '--exclude-standard').splitlines()
        if not all(name in visible for name in ('AGENTS.md', '.AGENTS/README.md', 'tools/agents/setup-tools.ps1')):
            raise ValueError('Shared toolkit sources are hidden from Git')
        if any(name.startswith(('.codex/', 'task_state/')) for name in visible):
            raise ValueError('Runtime files leaked into Git status')
        config = tomllib.loads((root/'.codex/config.toml').read_text(encoding='utf-8'))
        for server in config['mcp_servers'].values():
            if Path(server['cwd']).resolve() != root.resolve() or not Path(server['args'][0]).is_relative_to(root):
                raise ValueError('Machine paths were not regenerated for the checkout')
        if (root/'task_state').exists():
            raise ValueError('Installer imported task history')
        if any(entry['path'].startswith(('state/', 'machine/', 'payload/.codex/', 'payload/task_state/',
                                          'payload/.AGENTS/docs/', 'payload/.AGENTS/local/')) for entry in manifest['files']):
            raise ValueError('Export contains local data or review history')
        install(bundle, root)
        # Shared sources may be staged and tracked; the guard must allow both.
        run('git', '-C', str(root), 'add', '--', 'AGENTS.md', '.AGENTS', 'tools/agents')
        shared_index = digest(root/'.git/index')
        install(bundle, root)
        if digest(root/'.git/index') != shared_index:
            raise ValueError('Reinstall changed staged shared sources')
        run('git', '-C', str(root), 'hook', 'run', 'pre-commit')
        run('git', '-C', str(root), '-c', 'user.name=Toolkit verification', '-c', 'user.email=toolkit-fixture@localhost',
            '-c', 'commit.gpgSign=false', 'commit', '-q', '-m', 'Disposable shared toolkit')
        install(bundle, root)
        if run('git', '-C', str(root), 'status', '--porcelain').strip():
            raise ValueError('Reinstall changed tracked toolkit sources')
        # Deliberately stage ignored fixtures only in this disposable repository to exercise the guard.
        for relative in ('task_state/probe/TODO.md', '.AGENTS/local/probe/TODO.md'):
            target = root/relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text('local fixture only', encoding='utf-8')
        run('git', '-C', str(root), 'add', '-f', '--', '.codex/config.toml', 'task_state', '.AGENTS/local')
        refusal_index = digest(root/'.git/index')
        output = run('git', '-C', str(root), 'hook', 'run', 'pre-commit', reject='Commit blocked: local runtime file')
        if not all(name in output for name in ('.codex/config.toml', 'task_state/probe/TODO.md', '.AGENTS/local/probe/TODO.md')):
            raise ValueError('Hook missed a staged runtime path')
        run('powershell.exe', '-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
            str(root/'tools/agents/local-only.ps1'), '-Action', 'check', reject='Local runtime files are tracked/staged')
        install(bundle, root, reject='runtime paths overlap tracked/staged files')
        if digest(root/'.git/index') != refusal_index:
            raise ValueError('Runtime refusal changed the index')
        run('git', '-C', str(root), 'reset', '-q', 'HEAD', '--', *RUNTIME_PATHS)
        print('PASS: install/reinstall; regenerated paths with Cyrillic/spaces; no task/machine export')
        print('PASS: shared sources stage/commit normally; guard rejects runtime fixtures; index/history preserved')

        agents = root/'AGENTS.md'
        agents.write_bytes(original+b'\nlocal sentinel\n')
        custom_hash = digest(agents)
        install(bundle, root, reject='Existing local file differs')
        if digest(agents) != custom_hash:
            raise ValueError('Custom instructions overwritten')
        agents.write_bytes(original)
        hook = root/'.git/hooks/pre-commit'
        managed_hook = hook.read_bytes()
        hook.write_text('#!/bin/sh\n# custom hook sentinel\n', encoding='utf-8')
        install(bundle, root, reject='Custom pre-commit hook is preserved')
        if hook.read_text() != '#!/bin/sh\n# custom hook sentinel\n':
            raise ValueError('Custom hook overwritten')
        hook.write_bytes(managed_hook)
        config_path = root/'.codex/config.toml'
        managed_config = config_path.read_bytes()
        config_path.write_text('# custom config sentinel\n', encoding='utf-8')
        install(bundle, root, reject='Custom .codex/config.toml is preserved')
        if config_path.read_text() != '# custom config sentinel\n':
            raise ValueError('Custom config overwritten')
        config_path.write_bytes(managed_config)
        run('git', '-C', str(root), 'config', 'core.hooksPath', '.custom-hooks')
        install(bundle, root, reject='Custom core.hooksPath is preserved')
        run('git', '-C', str(root), 'config', '--unset', 'core.hooksPath')
        agents.write_bytes(original+b'\nstaged sentinel\n')
        run('git', '-C', str(root), 'add', '--', 'AGENTS.md')
        staged_index = digest(root/'.git/index')
        install(bundle, root, reject='Existing local file differs')
        if digest(root/'.git/index') != staged_index:
            raise ValueError('Refusal changed user index')
        agents.write_bytes(original)
        run('git', '-C', str(root), 'add', '--', 'AGENTS.md')
        if any(digest(root/p) != expected for p, expected in product_hashes.items()):
            raise ValueError('Product files changed')
        if run('git', '-C', str(root), 'status', '--porcelain').strip():
            raise ValueError('Refusal checks left tracked changes')
        if (digest(global_config) if global_config.exists() else None) != global_hash:
            raise ValueError('Global Codex config changed')
        print('PASS: differing instructions/custom hook/custom config/staged paths preserved; global config unchanged')
        # A Git checkout may change EOLs; exercise the installed hook against the checked-out template.
        run('git', '-C', str(root), '-c', 'core.autocrlf=true', 'checkout-index', '--force', '--all')
        if b'\r' in (root/'.AGENTS/templates/pre-commit').read_bytes():
            raise ValueError('Git checkout changed the executable hook template to CRLF')
        run('powershell.exe', '-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
            str(root/'tools/agents/setup-tools.ps1'), '-ConfigOnly')
        run('powershell.exe', '-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
            str(root/'tools/agents/local-only.ps1'), '-Action', 'check')
        print('PASS: Git checkout with core.autocrlf=true; LF hook template; setup and guard remain valid')
    finally:
        if stage.resolve().parent != temporary_root or not stage.name.startswith('bandastation-agent-test-'):
            raise ValueError('Unexpected temporary cleanup target')
        ordinary(stage)
        def remove_readonly(function, name, exception):
            target = Path(name)
            if not target.resolve().is_relative_to(stage.resolve()):
                raise ValueError('Temporary cleanup path escapes fixture')
            ordinary(target)
            os.chmod(target, stat.S_IWRITE | stat.S_IREAD)
            function(name)
        shutil.rmtree(stage, onerror=remove_readonly)
    print('PASS: portable installer fixture cleanup')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        raise SystemExit(str(error)) from error
